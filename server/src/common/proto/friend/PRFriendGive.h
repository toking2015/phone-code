#ifndef _PRFriendGive_H_
#define _PRFriendGive_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@赠送*/
class PRFriendGive : public SMsgHead
{
public:
    uint32 friend_id;    //好友角色id
    uint8 give_type;    //kFriendGiveOne
    uint32 active_score;    //活跃度
    std::vector< S2UInt32 > item_list;    //赠送数据 first = item_id   second = 数量

    PRFriendGive() : friend_id(0), give_type(0), active_score(0)
    {
        msg_cmd = 1458158398;
    }

    virtual ~PRFriendGive()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFriendGive(*this) );
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
            && TFVarTypeProcess( give_type, eType, stream, uiSize )
            && TFVarTypeProcess( active_score, eType, stream, uiSize )
            && TFVarTypeProcess( item_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFriendGive";
    }
};

#endif
