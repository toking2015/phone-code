#ifndef _SEffectSound_H_
#define _SEffectSound_H_

#include <weedong/core/seq/seq.h>
class SEffectSound : public wd::CSeq
{
public:
    uint8 attr;
    int16 time;
    std::string sound;

    SEffectSound() : attr(0), time(0)
    {
    }

    virtual ~SEffectSound()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SEffectSound(*this) );
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
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && TFVarTypeProcess( sound, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SEffectSound";
    }
};

#endif
