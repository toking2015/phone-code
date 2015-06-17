#ifndef _PRFriendRequest_H_
#define _PRFriendRequest_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SUserFriend.h>

/*请求加好友*/
class PRFriendRequest : public SMsgHead
{
public:
    uint32 target_id;    //请求者角色id
    SUserFriend info;

    PRFriendRequest() : target_id(0)
    {
        msg_cmd = 1217836923;
    }

    virtual ~PRFriendRequest()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendRequest(*this) );
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
        return "PRFriendRequest";
    }
};

#endif
