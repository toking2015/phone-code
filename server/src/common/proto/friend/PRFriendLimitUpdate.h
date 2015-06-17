#ifndef _PRFriendLimitUpdate_H_
#define _PRFriendLimitUpdate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/friend/SFriendLimit.h>

/*好友限制数据更新*/
class PRFriendLimitUpdate : public SMsgHead
{
public:
    SFriendLimit info;    //好友限制数据
    uint8 set_type;    //修改类型

    PRFriendLimitUpdate() : set_type(0)
    {
        msg_cmd = 1518846405;
    }

    virtual ~PRFriendLimitUpdate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendLimitUpdate(*this) );
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
        return "PRFriendLimitUpdate";
    }
};

#endif
