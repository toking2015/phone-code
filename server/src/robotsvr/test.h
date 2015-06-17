#ifndef __ROBOTSVR_TEST__
#define __ROBOTSVR_TEST__

#include "proto/common.h"
#include "proto/system.h"
#include "proto/user.h"
#include "common.h"
#include "netio.h"
#include "local.h"
#include "pack.h"
#include "misc.h"
#include "msg.h"
#include "log.h"

#define LINK_UNCONNECT  1
#define LINK_CONNECTING 2
#define LINK_CONNECTED  3

struct STestInfo
{
    std::string host;
    uint32      port;
    S2UInt32    uid;
    std::string msg_file;
    uint32      msg_file_size;
};

struct SLink
{
    uint32 socket;
    uint32 status;
    uint32 uid;
    uint32 session;
    uint32 msg_offset;
    bool   is_login;
};

class CTest
{
public:
    CTest() { }
    ~CTest(){ }

    void SetInfo(STestInfo info);
    void Check();
    void OnLogin(const PRSystemLogin &msg);
    void OnSessionCheck(const PRSystemSessionCheck &msg);
    void OnErrorCode(const PRSystemErrCode &msg);

    inline STestInfo GetInfo() { return m_info; }

private:
    SLink* FindBySocket(uint32 socket);
    void SendMsg(SLink &link);
    void OnClosed(SLink &link);

    static void OnConnected(void *param, int32 socket);
    static void OnRead(void* param, int32 socket, char* buff, int32 size);

private:
    typedef std::map<uint32, SLink> LinkMap; // key - uid

    STestInfo m_info;
    LinkMap   m_links;
};
#define theTest TSignleton<CTest>::Ref()

#endif
