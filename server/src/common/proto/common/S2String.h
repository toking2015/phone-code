#ifndef _S2String_H_
#define _S2String_H_

#include <weedong/core/seq/seq.h>
class S2String : public wd::CSeq
{
public:
    std::string first;
    std::string second;

    S2String()
    {
    }

    virtual ~S2String()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new S2String(*this) );
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
        return "S2String";
    }
};

#endif
