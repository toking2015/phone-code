#ifndef _PRFriendMsg_H_
#define _PRFriendMsg_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*返回消息*/
class PRFriendMsg : public SMsgHead
{
public:
    uint32 friend_id;    //好友角色id
    uint8 purview;    //用户权限
    std::string msg;    //消息正文

    PRFriendMsg() : friend_id(0), purview(0)
    {
        msg_cmd = 1577180918;
    }

    virtual ~PRFriendMsg()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendMsg(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType eType, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( friend_id, eType, stream, uiSize )
            && TFVarTypeProcess( purview, eType, stream, uiSize )
            && TFVarTypeProcess( msg, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendMsg";
    }
};

#endif
