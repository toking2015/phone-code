#ifndef _PRMarketBuyList_H_
#define _PRMarketBuyList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketSellCargo.h>

/*返回买方列表*/
class PRMarketBuyList : public SMsgHead
{
public:
    std::map< uint32, SMarketSellCargo > data;

    PRMarketBuyList()
    {
        msg_cmd = 1411658984;
    }

    virtual ~PRMarketBuyList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketBuyList(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketBuyList";
    }
};

#endif
