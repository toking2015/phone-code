#ifndef _PQMarketBuyRef_H_
#define _PQMarketBuyRef_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@刷新买方列表*/
class PQMarketBuyRef : public SMsgHead
{
public:
    uint8 use_coin;    //是否使用货币刷新[ kTrue, kFalse ]

    PQMarketBuyRef() : use_coin(0)
    {
        msg_cmd = 965244412;
    }

    virtual ~PQMarketBuyRef()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketBuyRef(*this) );
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
            && TFVarTypeProcess( use_coin, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketBuyRef";
    }
};

#endif
