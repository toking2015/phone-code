#ifndef _PRMarketBuyData_H_
#define _PRMarketBuyData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketSellCargo.h>

/*返回买方单数据*/
class PRMarketBuyData : public SMsgHead
{
public:
    uint8 set_type;    //kObjectAdd, kObjectUpdate, kObjectDel
    SMarketSellCargo data;

    PRMarketBuyData() : set_type(0)
    {
        msg_cmd = 1819854724;
    }

    virtual ~PRMarketBuyData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketBuyData(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketBuyData";
    }
};

#endif
