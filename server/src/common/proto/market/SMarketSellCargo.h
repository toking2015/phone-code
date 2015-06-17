#ifndef _SMarketSellCargo_H_
#define _SMarketSellCargo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*[卖方商品信息]*/
class SMarketSellCargo : public wd::CSeq
{
public:
    uint32 sid;    // 0 为跨服拍卖数据, 非0为指定服数据
    uint32 cargo_id;    //商品唯一ID
    uint32 role_id;    //上架货物主人
    S3UInt32 coin;    //上架货物剩余量
    uint8 percent;    //上架货物价值比值[ 80 - 180 ], 默认值 100
    uint32 start_time;    //上架时间
    uint32 down_time;    //下架时间
    std::string buy_name;    //购买人
    uint32 buy_count;    //购买数量
    uint32 money;    //已经卖出的价格

    SMarketSellCargo() : sid(0), cargo_id(0), role_id(0), percent(0), start_time(0), down_time(0), buy_count(0), money(0)
    {
    }

    virtual ~SMarketSellCargo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMarketSellCargo(*this) );
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
            && TFVarTypeProcess( sid, eType, stream, uiSize )
            && TFVarTypeProcess( cargo_id, eType, stream, uiSize )
            && TFVarTypeProcess( role_id, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && TFVarTypeProcess( start_time, eType, stream, uiSize )
            && TFVarTypeProcess( down_time, eType, stream, uiSize )
            && TFVarTypeProcess( buy_name, eType, stream, uiSize )
            && TFVarTypeProcess( buy_count, eType, stream, uiSize )
            && TFVarTypeProcess( money, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMarketSellCargo";
    }
};

#endif
