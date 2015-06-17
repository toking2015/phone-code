#ifndef _SBodySound_H_
#define _SBodySound_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SEffectSound.h>
#include <proto/client/STimeShaftSound.h>

class SBodySound : public wd::CSeq
{
public:
    std::string style;
    std::vector< SEffectSound > soundList;
    std::vector< STimeShaftSound > dataList;

    SBodySound()
    {
    }

    virtual ~SBodySound()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SBodySound(*this) );
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
            && TFVarTypeProcess( soundList, eType, stream, uiSize )
            && TFVarTypeProcess( dataList, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SBodySound";
    }
};

#endif
