#ifndef _SMarketBuyCargo_H_
#define _SMarketBuyCargo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*[买方商品信息]*/
class SMarketBuyCargo : public wd::CSeq
{
public:
    uint32 guid;    //用户内唯一 SUserCargo guid
    uint32 cargo_id;    //对应商品唯一Id, Id == 0 时为系统分配
    S3UInt32 coin;    //用户货架内容
    uint8 percent;    //上架货物价值比值[ 80 - 180 ], 默认值 100
    uint8 equip_type;    //装备类型, kEquipXXX
    uint8 equip_level;    //装备等级分段, 20级起, 每15级一分段

    SMarketBuyCargo() : guid(0), cargo_id(0), percent(0), equip_type(0), equip_level(0)
    {
    }

    virtual ~SMarketBuyCargo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMarketBuyCargo(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( cargo_id, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && TFVarTypeProcess( equip_type, eType, stream, uiSize )
            && TFVarTypeProcess( equip_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMarketBuyCargo";
    }
};

#endif
