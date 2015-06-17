#ifndef _S4UInt32_H_
#define _S4UInt32_H_

#include <weedong/core/seq/seq.h>
class S4UInt32 : public wd::CSeq
{
public:
    uint32 v1;
    uint32 v2;
    uint32 v3;
    uint32 v4;

    S4UInt32() : v1(0), v2(0), v3(0), v4(0)
    {
    }

    virtual ~S4UInt32()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new S4UInt32(*this) );
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
            && TFVarTypeProcess( v1, eType, stream, uiSize )
            && TFVarTypeProcess( v2, eType, stream, uiSize )
            && TFVarTypeProcess( v3, eType, stream, uiSize )
            && TFVarTypeProcess( v4, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "S4UInt32";
    }
};

#endif
