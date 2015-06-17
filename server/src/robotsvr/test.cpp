#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "test.h"

#define PRINT_MSG(name, msg) \
    LOG_INFO(">>> %s, uid=%u,session=%u,order=%u,action=%u", name, msg.role_id, msg.session, msg.order, msg.action)

#define SEND_MSG(req, socket)\
    wd::CStream stream;\
    stream.resize(sizeof(tag_pack_head));\
    stream << req;\
    CPack::fill_pack_head((tag_pack_head*)&stream[0], &stream[sizeof(tag_pack_head)], stream.length() - sizeof(tag_pack_head));\
    theNet.Write(socket, &stream[0], stream.length())

// -------------------------------------------
void CTest::SetInfo(STestInfo info)
{
    m_info = info;

    for(uint32 i = info.uid.first; i <= info.uid.second; ++i)
    {
        SLink link;
        link.uid      = i;
        link.status   = LINK_UNCONNECT;
        link.is_login = false;

        m_links[link.uid] = link;
    }
}

void CTest::Check()
{
    for(LinkMap::iterator iter = theTest.m_links.begin(); iter != theTest.m_links.end(); ++iter)
    {
        SLink &link = iter->second;

        // CHECK LINK STATUS
        switch(link.status)
        {
        case LINK_UNCONNECT:
            {
                char addr[128] = { 0 };
                snprintf(addr, sizeof(addr) - 1, "%s:%hu", m_info.host.c_str(), m_info.port);

                bool flag = theNet.Connect(addr, CTest::OnConnected, &link);
                if(flag)
                {
                    link.status = LINK_CONNECTING;
                }
                LOG_DEBUG("SLink: uid=%u, Connecting to [%s], and flag=%u", link.uid, addr, flag);

                break;
            }
        case LINK_CONNECTING:
            {
                //LOG_INFO("SLink: uid=%u, Connecting...", link.uid);
                break;
            }
        case LINK_CONNECTED:
            {
                theNet.Read(link.socket, CTest::OnRead, &link);
                break;
            }
        }

        // SEND MSG
        if(link.is_login)
        {
            if(link.msg_offset < m_info.msg_file_size)
            {
                SendMsg(link);
            }
        }
    }
}

void CTest::SendMsg(SLink &link)
{
    FILE *file = fopen(m_info.msg_file.c_str(), "r");
    while(true)
    {
        if(file == NULL)
        {
            LOG_ERROR("open file=%s failed", m_info.msg_file.c_str());
            break;
        }

        // SEEK FILE
        int32 seek_flag = fseek(file, link.msg_offset, SEEK_SET);
        if(seek_flag != 0)
        {
            LOG_ERROR("seek failed, ret=%d", seek_flag);
            break;
        }

        // READ BUFF
        const uint32 MSG_MAX = 512 * 1024;
        int8 buff[MSG_MAX];
        int32 read_size = fread(buff, sizeof(int8), MSG_MAX, file);
        if(read_size <= 0)
        {
            LOG_ERROR("read from=%u, and read size=%d", link.msg_offset, read_size);
        }

        // PARSE tag_pack_head
        uint32 msg_size_offset = sizeof(uint16) + sizeof(uint8) + sizeof(uint8);
        uint32 real_msg_size   = *((uint32*)(buff + msg_size_offset));
        if(real_msg_size > (uint32)read_size)
        {
            LOG_ERROR("the real msg size=%u > read_size=%u, and drop", real_msg_size, read_size);
            break;
        }

        // RESET SMsgHead
        uint32 uid_offset     = sizeof(tag_pack_head) + sizeof(uint32);
        uint32 session_offset = sizeof(tag_pack_head) + sizeof(uint32) + sizeof(uint32);
        *((uint32*)(buff + uid_offset))     = link.uid;
        *((uint32*)(buff + session_offset)) = link.session;

        // SEND MSG
        wd::CStream stream;
        stream.resize(sizeof(tag_pack_head));
        stream.write(buff, real_msg_size);
        CPack::fill_pack_head((tag_pack_head*)&stream[0], &stream[sizeof(tag_pack_head)], stream.length() - sizeof(tag_pack_head));
        theNet.Write(link.socket, &stream[0], stream.length());

        // SET LINK MSG OFFSET
        link.msg_offset += real_msg_size;
    }

    if(file != NULL)
    {
        fclose(file);
    }
}

void CTest::OnConnected(void *param, int32 socket)
{
    if(param == NULL)
    {
        return;
    }

    SLink *link = (SLink*)param;
    if(socket <= 0)
    {
        theTest.OnClosed(*link);
        LOG_ERROR("SLink: uid=%u, Connect failed", link->uid);
        return;
    }

    link->socket = socket;
    link->status = LINK_CONNECTED;
    LOG_INFO("SLink: uid=%u, Connected to [%s:%u], and socket=%u",
        link->uid, theTest.GetInfo().host.c_str(), theTest.GetInfo().port, socket);

    // LOGIN
    PQSystemLogin req;
    req.role_id = link->uid;
    SEND_MSG(req, link->socket);
}

void CTest::OnRead(void* param, int32 socket, char* buff, int32 size)
{
    if(size > 0)
    {
        thePack.PushData(local::outside, socket, buff, size);
    }
    else
    {
        SLink *link = theTest.FindBySocket((uint32)socket);
        if(link != NULL)
        {
            LOG_DEBUG("******** socket=%u, closed ********", socket);
            theTest.OnClosed(*link);
        }
    }
}

void CTest::OnClosed(SLink &link)
{
    theNet.Clear(link.socket);
    close(link.socket);

    link.status     = LINK_UNCONNECT;
    link.session    = 0;
    link.socket     = 0;
    link.msg_offset = 0;
    link.is_login   = false;
}

SLink* CTest::FindBySocket(uint32 socket)
{
    for(LinkMap::iterator iter = m_links.begin(); iter != m_links.end(); ++iter)
    {
        if(iter->second.socket == socket)
        {
            return &(iter->second);
        }
    }

    return NULL;
}

// --------------------- RECV MSG -----------------------
void CTest::OnLogin(const PRSystemLogin &msg)
{
    PRINT_MSG("PRSystemLogin", msg);

    LinkMap::iterator iter = m_links.find(msg.role_id);
    if(iter == m_links.end())
    {
        LOG_ERROR("cannot find link by uid=%u", msg.role_id);
        return;
    }

    SLink &link   = iter->second;
    link.session  = msg.session;
    link.is_login = true;

    // CHECK SESSION
    PQSystemSessionCheck req;
    req.role_id = link.uid;
    req.session = link.session;
    SEND_MSG(req, link.socket);
}

void CTest::OnSessionCheck(const PRSystemSessionCheck &msg)
{
    PRINT_MSG("PRSystemSessionCheck", msg);
}

void CTest::OnErrorCode(const PRSystemErrCode &msg)
{
    LOG_ERROR("!!! err_no=%u, err_desc=%u", msg.err_no, msg.err_desc);
}

