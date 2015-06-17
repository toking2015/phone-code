#ifndef _PQTempleTakeScoreReward_H_
#define _PQTempleTakeScoreReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 领取积分奖励*/
class PQTempleTakeScoreReward : public SMsgHead
{
public:
    uint32 reward_id;    // 奖励id

    PQTempleTakeScoreReward() : reward_id(0)
    {
        msg_cmd = 174141501;
    }

    virtual ~PQTempleTakeScoreReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTempleTakeScoreReward(*this) );
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
            && TFVarTypeProcess( reward_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTempleTakeScoreReward";
    }
};

#endif
