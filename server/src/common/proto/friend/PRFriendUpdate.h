#ifndef _PRFriendUpdate_H_
#define _PRFriendUpdate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SUserFriend.h>

/*好友数据更新*/
class PRFriendUpdate : public SMsgHead
{
public:
    SUserFriend info;    //好友数据
    uint8 set_type;    //修改类型

    PRFriendUpdate() : set_type(0)
    {
        msg_cmd = 1160251020;
    }

    virtual ~PRFriendUpdate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendUpdate(*this) );
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
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendUpdate";
    }
};

#endif
