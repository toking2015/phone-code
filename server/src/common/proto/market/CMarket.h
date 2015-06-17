#ifndef _CMarket_H_
#define _CMarket_H_

#include <weedong/core/seq/seq.h>
#include <proto/market/SMarketSellCargo.h>
#include <proto/market/SMarketIndices.h>

class CMarket : public wd::CSeq
{
public:
    uint32 social_time;    //跨服拍卖开始时间, gamesvr 使用
    uint32 global_id;    //全局id, 0为未初始化
    std::map< uint32, SMarketSellCargo > data_map;    //货品信息, < cargo_id, < data > >
    std::map< uint32, std::map< uint32, SMarketIndices > > indices_map;    //数据索引, < sid, < type_level, SMarketIndices > >
    std::map< uint32, std::vector< uint32 > > user_map;    //用户售卖索引, < role_id, < cargo_id > >
    std::map< uint32, std::map< uint32, std::vector< uint32 > > > down_map;    //下架索引 <timestamp, serverid, < cargo_id> >
    std::map< uint32, std::vector< uint32 > > sell_map;    //< serverid, < cargo_id > >;

    CMarket() : social_time(0), global_id(0)
    {
    }

    virtual ~CMarket()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CMarket(*this) );
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
            && TFVarTypeProcess( social_time, eType, stream, uiSize )
            && TFVarTypeProcess( global_id, eType, stream, uiSize )
            && TFVarTypeProcess( data_map, eType, stream, uiSize )
            && TFVarTypeProcess( indices_map, eType, stream, uiSize )
            && TFVarTypeProcess( user_map, eType, stream, uiSize )
            && TFVarTypeProcess( down_map, eType, stream, uiSize )
            && TFVarTypeProcess( sell_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CMarket";
    }
};

#endif
