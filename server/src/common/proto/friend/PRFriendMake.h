#ifndef _PRFriendMake_H_
#define _PRFriendMake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SUserFriend.h>

/*被加好友通知*/
class PRFriendMake : public SMsgHead
{
public:
    uint32 target_id;    //对方角色id
    SUserFriend info;    //好友数据

    PRFriendMake() : target_id(0)
    {
        msg_cmd = 1500965640;
    }

    virtual ~PRFriendMake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendMake(*this) );
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
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendMake";
    }
};

#endif
