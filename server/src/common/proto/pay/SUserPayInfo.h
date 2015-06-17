#ifndef _SUserPayInfo_H_
#define _SUserPayInfo_H_

#include <weedong/core/seq/seq.h>
/*==========================通迅结构==========================*/
class SUserPayInfo : public wd::CSeq
{
public:
    uint32 pay_sum;    //充值总额
    uint32 pay_count;    //充值次数
    uint32 month_time;    //月卡到期时间
    uint32 month_reward;    //月卡每天奖励

    SUserPayInfo() : pay_sum(0), pay_count(0), month_time(0), month_reward(0)
    {
    }

    virtual ~SUserPayInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserPayInfo(*this) );
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
            && TFVarTypeProcess( pay_sum, eType, stream, uiSize )
            && TFVarTypeProcess( pay_count, eType, stream, uiSize )
            && TFVarTypeProcess( month_time, eType, stream, uiSize )
            && TFVarTypeProcess( month_reward, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserPayInfo";
    }
};

#endif
