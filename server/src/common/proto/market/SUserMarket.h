#ifndef _SUserMarket_H_
#define _SUserMarket_H_

#include <weedong/core/seq/seq.h>
class SUserMarket : public wd::CSeq
{
public:

    SUserMarket()
    {
    }

    virtual ~SUserMarket()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserMarket(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "SUserMarket";
    }
};

#endif
