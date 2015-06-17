#ifndef _SUserTrialReward_H_
#define _SUserTrialReward_H_

#include <weedong/core/seq/seq.h>
/*==========================通迅结构==========================*/
class SUserTrialReward : public wd::CSeq
{
public:
    uint32 trial_id;    //试炼Id
    uint32 reward;    //奖励id
    uint32 flag;    //是否领取

    SUserTrialReward() : trial_id(0), reward(0), flag(0)
    {
    }

    virtual ~SUserTrialReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTrialReward(*this) );
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
            && TFVarTypeProcess( trial_id, eType, stream, uiSize )
            && TFVarTypeProcess( reward, eType, stream, uiSize )
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserTrialReward";
    }
};

#endif
