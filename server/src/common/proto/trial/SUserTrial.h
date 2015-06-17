#ifndef _SUserTrial_H_
#define _SUserTrial_H_

#include <weedong/core/seq/seq.h>
class SUserTrial : public wd::CSeq
{
public:
    uint32 trial_id;    //试炼Id
    uint32 trial_val;    //试炼值
    uint32 try_count;    //挑战次数
    uint32 reward_count;    //奖励领取次数
    uint32 max_single_val;    //单次最大值

    SUserTrial() : trial_id(0), trial_val(0), try_count(0), reward_count(0), max_single_val(0)
    {
    }

    virtual ~SUserTrial()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTrial(*this) );
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
            && TFVarTypeProcess( trial_val, eType, stream, uiSize )
            && TFVarTypeProcess( try_count, eType, stream, uiSize )
            && TFVarTypeProcess( reward_count, eType, stream, uiSize )
            && TFVarTypeProcess( max_single_val, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserTrial";
    }
};

#endif
