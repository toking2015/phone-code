#ifndef _S2Int32_H_
#define _S2Int32_H_

#include <weedong/core/seq/seq.h>
class S2Int32 : public wd::CSeq
{
public:
    int32 first;
    int32 second;

    S2Int32() : first(0), second(0)
    {
    }

    virtual ~S2Int32()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new S2Int32(*this) );
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
        return "S2Int32";
    }
};

#endif
