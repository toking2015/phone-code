#ifndef _PQFriendMsg_H_
#define _PQFriendMsg_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@消息*/
class PQFriendMsg : public SMsgHead
{
public:
    uint32 target_id;    //对方角色id
    std::string msg;    //消息正文

    PQFriendMsg() : target_id(0)
    {
        msg_cmd = 654453972;
    }

    virtual ~PQFriendMsg()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFriendMsg(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( msg, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFriendMsg";
    }
};

#endif
