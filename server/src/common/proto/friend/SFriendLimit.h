#ifndef _SFriendLimit_H_
#define _SFriendLimit_H_

#include <weedong/core/seq/seq.h>
class SFriendLimit : public wd::CSeq
{
public:
    uint32 friend_id;    //好友id
    uint32 time_limit;    //最后一次赠送时间点  针对活跃度
    uint32 type_limit;    //当天重置时间点    针对物品
    uint32 num_limit;    //数量限制

    SFriendLimit() : friend_id(0), time_limit(0), type_limit(0), num_limit(0)
    {
    }

    virtual ~SFriendLimit()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFriendLimit(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( friend_id, eType, stream, uiSize )
            && TFVarTypeProcess( time_limit, eType, stream, uiSize )
            && TFVarTypeProcess( type_limit, eType, stream, uiSize )
            && TFVarTypeProcess( num_limit, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFriendLimit";
    }
};

#endif
