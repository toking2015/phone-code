#ifndef _PRSystemOrder_H_
#define _PRSystemOrder_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSystemOrder : public SMsgHead
{
public:
    uint32 min;
    uint32 max;

    PRSystemOrder() : min(0), max(0)
    {
        msg_cmd = 1801311003;
    }

    virtual ~PRSystemOrder()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemOrder(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( min, eType, stream, uiSize )
            && TFVarTypeProcess( max, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSystemOrder";
    }
};

#endif
