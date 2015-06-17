#ifndef _SEffect_H_
#define _SEffect_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SEffectItem.h>

class SEffect : public wd::CSeq
{
public:
    std::string style;
    int16 scale;
    std::vector< SEffectItem > list;

    SEffect() : scale(0)
    {
    }

    virtual ~SEffect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SEffect(*this) );
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
            && TFVarTypeProcess( style, eType, stream, uiSize )
            && TFVarTypeProcess( scale, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SEffect";
    }
};

#endif
