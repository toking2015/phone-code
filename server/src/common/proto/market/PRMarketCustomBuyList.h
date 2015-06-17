#ifndef _PRMarketCustomBuyList_H_
#define _PRMarketCustomBuyList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketSellCargo.h>

class PRMarketCustomBuyList : public SMsgHead
{
public:
    uint8 equip;    //YY甲类型 kEquipYYY
    uint16 level;    //T1, T2 ... Tx 对应的等级( 20, 35, 50, 65, 80, 95, 110, 125, 140, 155 )
    std::vector< SMarketSellCargo > data;

    PRMarketCustomBuyList() : equip(0), level(0)
    {
        msg_cmd = 1472681061;
    }

    virtual ~PRMarketCustomBuyList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketCustomBuyList(*this) );
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
            && TFVarTypeProcess( equip, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketCustomBuyList";
    }
};

#endif
