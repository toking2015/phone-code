#ifndef _S4Int32_H_
#define _S4Int32_H_

#include <weedong/core/seq/seq.h>
class S4Int32 : public wd::CSeq
{
public:
    int32 v1;
    int32 v2;
    int32 v3;
    int32 v4;

    S4Int32() : v1(0), v2(0), v3(0), v4(0)
    {
    }

    virtual ~S4Int32()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new S4Int32(*this) );
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
        return "S4Int32";
    }
};

#endif
