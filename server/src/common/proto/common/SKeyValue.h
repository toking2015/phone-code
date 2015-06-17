#ifndef _SKeyValue_H_
#define _SKeyValue_H_

#include <weedong/core/seq/seq.h>
class SKeyValue : public wd::CSeq
{
public:
    std::string key;
    uint32 val;

    SKeyValue() : val(0)
    {
    }

    virtual ~SKeyValue()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SKeyValue(*this) );
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
            && TFVarTypeProcess( key, eType, stream, uiSize )
            && TFVarTypeProcess( val, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SKeyValue";
    }
};

#endif
