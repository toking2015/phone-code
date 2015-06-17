#ifndef _STimeShaftSound_H_
#define _STimeShaftSound_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SEffectSound.h>

class STimeShaftSound : public wd::CSeq
{
public:
    std::string flag;
    uint8 effectIndex;
    std::vector< SEffectSound > list;

    STimeShaftSound() : effectIndex(0)
    {
    }

    virtual ~STimeShaftSound()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STimeShaftSound(*this) );
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
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && TFVarTypeProcess( effectIndex, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STimeShaftSound";
    }
};

#endif
