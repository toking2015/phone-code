#ifndef _PQTakeSignSumReward_H_
#define _PQTakeSignSumReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 领取累计签到奖励*/
class PQTakeSignSumReward : public SMsgHead
{
public:
    uint32 reward_id;    // 奖励id

    PQTakeSignSumReward() : reward_id(0)
    {
        msg_cmd = 664307434;
    }

    virtual ~PQTakeSignSumReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTakeSignSumReward(*this) );
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
        return "PQTakeSignSumReward";
    }
};

#endif
