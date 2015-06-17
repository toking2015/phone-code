#ifndef _SActionEffect_H_
#define _SActionEffect_H_

#include <weedong/core/seq/seq.h>
/*==========================閫氳繀缁撴瀯==========================*/
class SActionEffect : public wd::CSeq
{
public:
    uint8 Index;
    uint32 AckEffect;
    uint32 FireEffect;
    uint32 TargetEffect;
    std::vector< int16 > TimeShaftDataList;

    SActionEffect() : Index(0), AckEffect(0), FireEffect(0), TargetEffect(0)
    {
    }

    virtual ~SActionEffect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SActionEffect(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( Index, type, stream, uiSize )
            && TFVarTypeProcess( AckEffect, type, stream, uiSize )
            && TFVarTypeProcess( FireEffect, type, stream, uiSize )
            && TFVarTypeProcess( TargetEffect, type, stream, uiSize )
            && TFVarTypeProcess( TimeShaftDataList, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "SActionEffect";
    }
};

#endif
