#ifndef _S2UInt16_H_
#define _S2UInt16_H_

#include <weedong/core/seq/seq.h>
class S2UInt16 : public wd::CSeq
{
public:
    uint16 first;
    uint16 second;

    S2UInt16() : first(0), second(0)
    {
    }

    virtual ~S2UInt16()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new S2UInt16(*this) );
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
            && TFVarTypeProcess( first, eType, stream, uiSize )
            && TFVarTypeProcess( second, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "S2UInt16";
    }
};

#endif
