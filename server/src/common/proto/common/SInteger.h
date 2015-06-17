#ifndef _SInteger_H_
#define _SInteger_H_

#include <weedong/core/seq/seq.h>
class SInteger : public wd::CSeq
{
public:
    uint32 value;

    SInteger() : value(0)
    {
    }

    virtual ~SInteger()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SInteger(*this) );
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
        return "SInteger";
    }
};

#endif
