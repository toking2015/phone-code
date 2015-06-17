#ifndef _SFightClientSeed_H_
#define _SFightClientSeed_H_

#include <weedong/core/seq/seq.h>
class SFightClientSeed : public wd::CSeq
{
public:
    uint32 value;

    SFightClientSeed() : value(0)
    {
    }

    virtual ~SFightClientSeed()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightClientSeed(*this) );
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
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightClientSeed";
    }
};

#endif
