#ifndef _STombTarget_H_
#define _STombTarget_H_

#include <weedong/core/seq/seq.h>
/*大墓地-印佳*/
class STombTarget : public wd::CSeq
{
public:
    uint32 attr;    //怪物玩家
    uint32 target_id;    //id
    uint32 reward;    //奖励是否领取

    STombTarget() : attr(0), target_id(0), reward(0)
    {
    }

    virtual ~STombTarget()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STombTarget(*this) );
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
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( reward, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STombTarget";
    }
};

#endif
