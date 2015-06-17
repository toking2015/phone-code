#ifndef _PRStrengthBuy_H_
#define _PRStrengthBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRStrengthBuy : public SMsgHead
{
public:
    uint32 value;    //购买获得体力

    PRStrengthBuy() : value(0)
    {
        msg_cmd = 1814060550;
    }

    virtual ~PRStrengthBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRStrengthBuy(*this) );
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
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRStrengthBuy";
    }
};

#endif
