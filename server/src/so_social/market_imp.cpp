#include "market_imp.h"
#include "market_dc.h"
#include "resource/r_marketext.h"
#include "proto/item.h"
#include "proto/coin.h"
#include "proto/constant.h"
#include "server.h"
#include "social_imp.h"
#include "local.h"
#include "social_dc.h"

namespace market
{

#define TYPE_LEVEL( t, l ) ( ( t << 16 ) + l )

std::vector< uint32 >& switch_cargo_map( uint32 sid, CMarketData::SData* market )
{
    uint32 type_level = TYPE_LEVEL( market->type, market->level );

    if ( market->group == kMarketCargoTypePaper )
        return theMarketDC.db().indices_map[ sid ][ type_level ].paper_list;

    return theMarketDC.db().indices_map[ sid ][ type_level ].material_list;
}

void cargo_up( uint32 sid, uint32 rid, S3UInt32 coin, uint8 precent )
{
    if ( coin.val <= 0 )
        return;

    CMarketData::SData* market = theMarketExt.Find( coin.objid );
    if ( market == NULL )
        return;

    //分配唯一id
    uint32 cargo_id = theMarketDC.alloc_id();

    //记录数据
    SMarketSellCargo& cargo = theMarketDC.db().data_map[ cargo_id ];
    cargo.sid           = sid;
    cargo.cargo_id      = cargo_id;
    cargo.role_id       = rid;
    cargo.coin          = coin;
    cargo.percent       = precent;
    cargo.start_time    = server::local_time();
    cargo.down_time     = cargo.start_time + 24*3600;

    //记录购买索引
    std::vector< uint32 >& list = switch_cargo_map( sid, market );

    list.push_back( cargo_id );

    //记录用户索引
    theMarketDC.db().user_map[ rid ].push_back( cargo_id );
    theMarketDC.db().down_map[SERVER_ID(rid)][TIMETOMIN(cargo.down_time)].push_back(cargo_id);

    //回发用户数据
    PRMarketSellData msg;
    msg.role_id = rid;

    msg.set_type = kObjectAdd;
    msg.data = cargo;

    social::write( SERVER_ID( rid ), msg );

    //保存数据
    modify_db_data( kObjectAdd, cargo );
}

void cargo_remove( uint32 cargo_id )
{
    std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
    if ( iter == theMarketDC.db().data_map.end() )
        return;

    CMarketData::SData* market = theMarketExt.Find( iter->second.coin.objid );
    if ( market == NULL )
        return;

    //删除用户索引
    {
        std::vector<uint32>& list = theMarketDC.db().user_map[ iter->second.role_id ];
        std::vector<uint32>::iterator iter = std::find(list.begin(), list.end(), cargo_id );
        if ( iter != list.end() )
            list.erase(iter);
    }

    //删除购买索引
    {
        std::vector< uint32 >& list = switch_cargo_map( iter->second.sid, market );
        std::vector<uint32>::iterator iter = std::find(list.begin(), list.end(), cargo_id );
        if ( iter != list.end() )
            list.erase(iter);
    }

    //删除数据
    theMarketDC.db().data_map.erase( iter );
}
void cargo_down( uint32 rid, uint32 cargo_id )
{
    std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
    if ( iter == theMarketDC.db().data_map.end() )
        return;

    if ( iter->second.role_id != rid )
        return;

    //回发协议
    PRMarketSellData msg;
    msg.role_id = rid;
    msg.set_type = kObjectDel;
    msg.data = iter->second;

    social::write( SERVER_ID( rid ), msg );

    PRMarketCargoDown msg_down;
    msg_down.role_id = rid;
    msg_down.data = iter->second;
    social::write( SERVER_ID( rid ), msg_down);

    //数据库修改
    modify_db_data( kObjectDel, iter->second );

    //移除本地数据
    cargo_remove( cargo_id );
}

void cargo_buy( uint32 rid, uint32 cargo_id, uint32 count, uint32 value, uint8 percent )
{
    PRMarketBuy msg;
    msg.role_id = rid;
    msg.value = value;

    do
    {
        std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
        if ( iter == theMarketDC.db().data_map.end() )
        {
            msg.result = kErrMarketCargoNoExist;
            break;
        }

        SMarketSellCargo& cargo = iter->second;
        if ( cargo.coin.val < count )
        {
            msg.result = kErrMarketCargoNotEnough;
            break;
        }

        if ( cargo.percent != percent )
        {
            msg.result = kErrMarketCargoChange;
            break;
        }

        CMarketData::SData* market = theMarketExt.Find( cargo.coin.objid );
        if ( market == NULL )
        {
            msg.result = kErrMarketCargoNoExchange;
            break;
        }

        uint32 money = market->value * count * cargo.percent / 100;
        if ( value != money )
        {
            msg.result = kErrCoinLack;
            break;
        }

        msg.coin.cate   = cargo.coin.cate;
        msg.coin.objid  = cargo.coin.objid;
        msg.coin.val    = count;

        cargo.coin.val -= count;
        cargo.money += money;

        //向售卖方发送售出记录
        {
            PRMarketSellData rep;
            rep.role_id = cargo.role_id;

            if ( cargo.coin.val <= 0 )
                rep.set_type = kObjectDel;
            else
                rep.set_type = kObjectUpdate;

            rep.data = cargo;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        //向售卖方发送售出后数据记录
        {
            PRMarketSell rep;
            rep.role_id = cargo.role_id;

            rep.cargo_id = cargo.cargo_id;
            rep.name    = theSocialDC.db().user_map[ rid ].name;
            rep.value   = money;
            rep.coin.cate   = cargo.coin.cate;
            rep.coin.objid  = cargo.coin.objid;
            rep.coin.val    = count;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        theMarketDC.db().sell_map[SERVER_ID(cargo.role_id)].push_back(cargo.cargo_id);

        //修改数据
        if ( cargo.coin.val <= 0 )
        {
            //数据库修改
            modify_db_data( kObjectDel, cargo );

            //移除本地数据
            cargo_remove( cargo_id );
        }
        else
        {
            //数据库修改
            modify_db_data( kObjectUpdate, cargo );
        }
    }
    while(0);

    social::write( SERVER_ID( rid ), msg );
}

bool cargo_check( uint32 sid, uint32 item_id, uint32 value )
{
    CMarketData::SData* market = theMarketExt.Find( item_id );
    if ( market == NULL )
        return false;

    uint32 type_level = TYPE_LEVEL( market->type, market->level );
    SMarketIndices& indices = theMarketDC.db().indices_map[ sid ][ type_level ];

    std::vector< uint32 >* array = NULL;
    switch ( market->group )
    {
    case kMarketCargoTypePaper:
        {
            array = &indices.paper_list;
        }
        break;
    case kMarketCargoTypeMaterial:
        {
            array = &indices.material_list;
        }
        break;
    }

    if ( array == NULL )
        return false;

    uint32 count = 0;
    for ( std::vector< uint32 >::iterator iter = array->begin();
        iter != array->end();
        ++iter )
    {
        std::map< uint32, SMarketSellCargo >::iterator i = theMarketDC.db().data_map.find( *iter );
        if ( i == theMarketDC.db().data_map.end() )
            continue;

        count += i->second.coin.val;

        if ( count >= value )
            return true;
    }

    return false;
}

void cargo_buy_all( uint32 rid, std::vector< S3UInt32 >& coins, uint32 value, uint32 percent )
{
    PRMarketBuyAll msg;
    msg.role_id = rid;
    msg.value = value;

    //购买货品数量验证
    for ( std::vector< S3UInt32 >::iterator iter = coins.begin();
        iter != coins.end();
        ++iter )
    {
        uint32 cargo_id = iter->cate;
        uint32 count = iter->objid;
        uint32 value = iter->val;

        std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
        if ( iter == theMarketDC.db().data_map.end() )
        {
            msg.result = kErrMarketCargoNoExist;
            break;
        }

        SMarketSellCargo& cargo = iter->second;
        if ( cargo.coin.val < count )
        {
            msg.result = kErrMarketCargoNotEnough;
            break;
        }

        if ( cargo.percent != percent )
        {
            msg.result = kErrMarketCargoChange;
            break;
        }

        CMarketData::SData* market = theMarketExt.Find( cargo.coin.objid );
        if ( market == NULL )
        {
            msg.result = kErrMarketCargoNoExchange;
            break;
        }

        uint32 money = market->value * count * cargo.percent / 100;
        if ( value != money )
        {
            msg.result = kErrCoinLack;
            break;
        }
    }

    //不满足条件
    if ( 0 != msg.result )
    {
        social::write( SERVER_ID( rid ), msg );
        return;
    }

    //购买货品
    for ( std::vector< S3UInt32 >::iterator iter = coins.begin();
        iter != coins.end();
        ++iter )
    {
        uint32 cargo_id = iter->cate;
        uint32 count = iter->objid;
        uint32 value = iter->val;

        std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
        if ( iter == theMarketDC.db().data_map.end() )
        {
            msg.result = kErrMarketCargoNoExist;
            break;
        }

        SMarketSellCargo& cargo = iter->second;

        msg.coin.cate   = cargo.coin.cate;
        msg.coin.objid  = cargo.coin.objid;
        msg.coin.val    += count;

        cargo.coin.val -= count;
        cargo.money += value;

        //向售卖方发送售出记录
        {
            PRMarketSellData rep;
            rep.role_id = cargo.role_id;

            if ( cargo.coin.val <= 0 )
                rep.set_type = kObjectDel;
            else
                rep.set_type = kObjectUpdate;

            rep.data = cargo;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        //向售卖方发送售出后数据记录
        {
            PRMarketSell rep;
            rep.role_id = cargo.role_id;

            rep.cargo_id = cargo.cargo_id;
            rep.name    = theSocialDC.db().user_map[ rid ].name;
            rep.value   = value;
            rep.coin.cate   = cargo.coin.cate;
            rep.coin.objid  = cargo.coin.objid;
            rep.coin.val    = count;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        //修改数据
        if ( cargo.coin.val <= 0 )
        {
            //数据库修改
            modify_db_data( kObjectDel, cargo );

            //移除本地数据
            cargo_remove( cargo_id );
        }
        else
        {
            //数据库修改
            modify_db_data( kObjectUpdate, cargo );
        }
    }

    social::write( SERVER_ID( rid ), msg );
}

void batch_match( uint32 sid, uint32 rid, std::vector< S3UInt32 >& coins )
{
    PRMarketBatchMatch msg;
    msg.role_id = rid;

    //购买货品
    for ( std::vector< S3UInt32 >::iterator iter = coins.begin();
        iter != coins.end();
        ++iter )
    {
        //货币类型验证
        if ( iter->cate != kCoinItem )
        {
            msg.result = kErrMarketCargoNoExist;
            social::write( SERVER_ID( rid ), msg );
            return;
        }

        //货币交易信息验证
        CMarketData::SData* market = theMarketExt.Find( iter->objid );
        if ( market == NULL )
        {
            msg.result = kErrMarketCargoNoExist;
            social::write( SERVER_ID( rid ), msg );
            return;
        }

        //获取索引数据
        uint32 type_level = TYPE_LEVEL( market->type, market->level );
        SMarketIndices& indices = theMarketDC.db().indices_map[ sid ][ type_level ];

        //拷贝索引列表
        std::vector< uint32 > array;
        switch ( market->group )
        {
        case kMarketCargoTypePaper:
            {
                array = indices.paper_list;
            }
            break;
        case kMarketCargoTypeMaterial:
            {
                array = indices.material_list;
            }
            break;
        }

        for(;;)
        {
            //购买数量不足
            if ( array.empty() )
            {
                //真充系统补给数据
                SMarketMatch match;
                match.coin.cate     = kCoinItem;
                match.coin.objid    = iter->objid;
                match.coin.val      = iter->val;
                match.percent       = 250;

                msg.cargos.push_back( match );

                iter->val = 0;
                break;
            }

            //随机购买数据
            uint32 idx = TRand( (uint32)0, (uint32)array.size() );
            uint32 cargo_id = array[ idx ];

            //移除索引
            array.erase( array.begin() + idx );

            //获取售卖数据
            SMarketSellCargo& cargo = theMarketDC.db().data_map[ cargo_id ];

            //填充匹配信息
            SMarketMatch match;
            match.cargo_id      = cargo.cargo_id;
            match.coin.cate     = cargo.coin.cate;
            match.coin.objid    = cargo.coin.objid;
            match.coin.val      = std::min( cargo.coin.val, iter->val );
            match.percent       = cargo.percent;

            msg.cargos.push_back( match );

            //修复购买需求量
            iter->val -= match.coin.val;

            //判断是否需要跳出循环购买一下物品
            if ( iter->val <= 0 )
                break;
        }
    }

    social::write( SERVER_ID( rid ), msg );
}

void batch_buy( uint32 sid, uint32 rid, std::vector< SMarketMatch >& cargos, uint32 value, uint32 path )
{
    PRMarketBatchBuy msg;
    msg.role_id = rid;
    msg.value = value;

    msg.path = path;

    //购买货品数量和价格验证
    for ( std::vector< SMarketMatch >::iterator i = cargos.begin();
        i != cargos.end();
        ++i )
    {
        //基本容错
        if ( i->coin.val <= 0 )
            continue;

        if ( i->coin.cate != kCoinItem )
        {
            msg.result = kErrMarketCargoNoExist;
            social::write( SERVER_ID( rid ), msg );
            return;
        }

        if ( i->coin.objid == 0 || i->coin.val <= 0 )
        {
            msg.result = kErrMarketCargoNotEnough;
            social::write( SERVER_ID( rid ), msg );
            return;
        }

        //跳过系统补给货物校验
        if ( i->cargo_id == 0 )
            continue;

        //货物校验
        std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( i->cargo_id );
        if ( iter == theMarketDC.db().data_map.end() )
        {
            msg.result = kErrMarketCargoNoExist;
            social::write( SERVER_ID( rid ), msg );
            return;
        }

        if ( iter->second.coin.objid != i->coin.objid
            || iter->second.coin.val < i->coin.val
            || iter->second.percent != i->percent )
        {
            msg.result = kErrMarketCargoNotEnough;
            social::write( SERVER_ID( rid ), msg );
            return;
        }
    }


    //购买货品
    std::map< uint32, uint32 > items;
    for ( std::vector< SMarketMatch >::iterator iter = cargos.begin();
        iter != cargos.end();
        ++iter )
    {
        if ( iter->coin.val == 0 )
            continue;

        CMarketData::SData* market = theMarketExt.Find( iter->coin.objid );
        if ( market == NULL )
            continue;

        uint32 cargo_id = iter->cargo_id;

        if ( cargo_id == 0 )
        {
            items[ iter->coin.objid ] += iter->coin.val;
            continue;
        }

        SMarketSellCargo& cargo = theMarketDC.db().data_map[ cargo_id ];
        cargo.coin.val -= iter->coin.val;

        //计算购买价格
        uint32 money = market->value * iter->coin.val * cargo.percent / 100;

        //向售卖方发送售出记录
        {
            PRMarketSellData rep;
            rep.role_id = cargo.role_id;

            if ( cargo.coin.val <= 0 )
                rep.set_type = kObjectDel;
            else
                rep.set_type = kObjectUpdate;

            rep.data = cargo;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        //向售卖方发送售出后数据记录
        {
            PRMarketSell rep;
            rep.role_id = cargo.role_id;
            rep.cargo_id = cargo.cargo_id;

            rep.name    = theSocialDC.db().user_map[ rid ].name;
            rep.value   = money;
            rep.coin.cate   = cargo.coin.cate;
            rep.coin.objid  = cargo.coin.objid;
            rep.coin.val    = iter->coin.val;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        //修改数据
        if ( cargo.coin.val <= 0 )
        {
            //数据库修改
            modify_db_data( kObjectDel, cargo );

            //移除本地数据
            cargo_remove( cargo_id );
        }
        else
        {
            //数据库修改
            modify_db_data( kObjectUpdate, cargo );
        }

        items[ iter->coin.objid ] += iter->coin.val;
    }

    for ( std::map< uint32, uint32 >::iterator iter = items.begin();
        iter != items.end();
        ++iter )
    {
        S3UInt32 coin;
        coin.cate = kCoinItem;
        coin.objid = iter->first;
        coin.val = iter->second;

        msg.coins.push_back( coin );
    }

    social::write( SERVER_ID( rid ), msg );
}

void cargo_change( uint32 rid, uint32 cargo_id, uint8 percent )
{
    std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
    if ( iter == theMarketDC.db().data_map.end() )
        return;

    if ( iter->second.role_id != rid )
        return;

    CMarketData::SData* market = theMarketExt.Find( iter->second.coin.objid );
    if ( market == NULL )
        return;

    SMarketSellCargo& cargo = iter->second;

    cargo.percent = percent;

    //回发用户数据
    PRMarketSellData msg;
    msg.role_id = rid;

    msg.set_type = kObjectUpdate;
    msg.data = cargo;

    social::write( SERVER_ID( rid ), msg );

    //数据库修改
    modify_db_data( kObjectUpdate, cargo );
}

struct cargo_sid_reset
{
    uint32 sid;
    cargo_sid_reset( uint32 id ) : sid(id){}

    void operator()( uint32 cargo_id )
    {
        std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
        if ( iter == theMarketDC.db().data_map.end() )
            return;

        iter->second.sid = cargo_id;
    }
};
void cargo_reset( uint32 sid )
{
    if ( sid == 0 )
        return;

    std::map< uint32, std::map< uint32, SMarketIndices > >::iterator iter = theMarketDC.db().indices_map.find( sid );
    if ( iter == theMarketDC.db().indices_map.end() )
        return;

    std::map< uint32, SMarketIndices >& social_map = theMarketDC.db().indices_map[0];

    for ( std::map< uint32, SMarketIndices >::iterator i = iter->second.begin();
        i != iter->second.end();
        ++i )
    {
        //图纸数据处理
        {
            std::vector< uint32 >& list = social_map[ i->first ].paper_list;
            list.insert( list.end(), i->second.paper_list.begin(), i->second.paper_list.end() );
            std::for_each( i->second.paper_list.begin(), i->second.paper_list.end(), cargo_sid_reset( sid ) );
        }

        //材料数据处理
        {
            std::vector< uint32 >& list = social_map[ i->first ].material_list;
            list.insert( list.end(), i->second.material_list.begin(), i->second.material_list.end() );
            std::for_each( i->second.material_list.begin(), i->second.material_list.end(), cargo_sid_reset( sid ) );
        }
    }

    theMarketDC.db().indices_map.erase( iter );

    //通知数据库修改
    PQMarketSocialReset msg;
    msg.sid = sid;

    local::write( local::sharedb, msg );
}

void get_buy_list( uint32 sid, uint32 rid, uint32 level )
{
    //等级列表
    int32 level_list[] = { 20, 35, 50, 65, 80, 95, 110, 125, 140, 155 };

    PRMarketBuyList msg;
    msg.role_id = rid;

    std::map< uint32, SMarketIndices >& map = theMarketDC.db().indices_map[ sid ];
    for ( int32 i = 0; i < (int32)( sizeof( level_list ) / sizeof( int32 ) ); ++i )
    {
        uint32 level_limit = level_list[i];

        if ( level + 5 < level_limit )
            break;

        for ( int32 j = 1; j <= 4; ++j )
        {
            uint32 type = TYPE_LEVEL( j, level_limit );

            SMarketIndices& indices = map[ type ];

            std::vector< uint32 > paper     = indices.paper_list;
            std::vector< uint32 > material  = indices.material_list;

            //随机10个图纸和10个材料
            for ( int32 k = 0; k < 10; ++k )
            {
                if ( !paper.empty() )
                {
                    uint32 idx = TRand( (uint32)0, (uint32)paper.size() );
                    uint32 id = paper[ idx ];

                    paper.erase( paper.begin() + idx );

                    msg.data[ id ] = theMarketDC.db().data_map[ id ];
                }

                if ( !material.empty() )
                {
                    uint32 idx = TRand( (uint32)0, (uint32)material.size() );
                    uint32 id = material[ idx ];

                    material.erase( material.begin() + idx );

                    msg.data[ id ] = theMarketDC.db().data_map[ id ];
                }
            }
        }
    }

    social::write( SERVER_ID( rid ), msg );
}

void get_custom_list( uint32 sid, uint32 rid, uint8 equip, uint16 level )
{
    PRMarketCustomBuyList msg;
    msg.role_id = rid;
    msg.equip = equip;
    msg.level = level;

    do
    {
        //装备甲分类容错
        if ( equip < 1 || equip > 4 )
            break;

        std::map< uint32, SMarketIndices >& map = theMarketDC.db().indices_map[ sid ];

        uint32 equip_type = TYPE_LEVEL( equip, level );

        SMarketIndices& indices = map[ equip_type ];

        //不使用指针和引用, 需要copy
        std::vector< uint32 > copy_array;
        std::vector< uint32 >* list_array[] = { &indices.paper_list, &indices.material_list };

        //默认数据
        SMarketSellCargo default_cargo;
        default_cargo.coin.cate     = kCoinItem;
        default_cargo.coin.val      = 9999;
        default_cargo.percent       = 250;

        //添加默认数据
        {
            std::vector< CMarketData::SData* > array = theMarketExt.find_custom( equip, level, kMarketCargoTypePaper );
            for ( std::vector< CMarketData::SData* >::iterator i = array.begin();
                i != array.end();
                ++i )
            {
                //压入系统默认购买
                default_cargo.coin.objid    = (*i)->item_id;

                msg.data.push_back( default_cargo );
            }
        }
        {
            std::vector< CMarketData::SData* > array = theMarketExt.find_custom( equip, level, kMarketCargoTypeMaterial );
            for ( std::vector< CMarketData::SData* >::iterator i = array.begin();
                i != array.end();
                ++i )
            {
                //压入系统默认购买
                default_cargo.coin.objid    = (*i)->item_id;

                msg.data.push_back( default_cargo );
            }
        }

        //最高50条数据
        uint32 max_count = 50;
        for ( int32 i = 0; i < 2; ++i )
        {
            //小于等于 50 条数据直接 copy
            if ( list_array[i]->size() <= max_count )
            {
                for ( std::vector< uint32 >::iterator iter = list_array[i]->begin();
                    iter != list_array[i]->end();
                    ++iter )
                {
                    uint32 id = *iter;

                    msg.data.push_back( theMarketDC.db().data_map[ id ] );
                }

                continue;
            }

            //随机装备
            copy_array = *list_array[i];
            for ( uint32 k = 0; k < max_count; ++k )
            {
                if ( copy_array.empty() )
                    break;

                uint32 idx = TRand( (uint32)0, (uint32)copy_array.size() );
                uint32 id = copy_array[ idx ];

                copy_array.erase( copy_array.begin() + idx );

                msg.data.push_back( theMarketDC.db().data_map[ id ] );
            }
        }
    }
    while(0);

    social::write( SERVER_ID( rid ), msg );
}

void get_sell_list( uint32 sid, uint32 rid )
{
    PRMarketSellList msg;
    msg.role_id = rid;

    do
    {
        std::map< uint32, std::vector< uint32 > >::iterator iter = theMarketDC.db().user_map.find( rid );
        if ( iter == theMarketDC.db().user_map.end() )
            break;

        for ( int32 i = 0; i < (int32)iter->second.size(); ++i )
        {
            uint32 cargo_id = iter->second[i];

            msg.data[ cargo_id ] = theMarketDC.db().data_map[ cargo_id ];
        }
    }
    while(0);

    social::write( SERVER_ID( rid ), msg );
}

void modify_db_data( uint32 set_type, SMarketSellCargo& cargo )
{
    PRMarketSellData msg;

    msg.set_type = set_type;
    msg.data = cargo;

    local::write( local::sharedb, msg );
}

void down_time_out( uint32 sid )
{
    if ( 0 == sid )
        return;

    uint32 time_now = server::local_time();
    std::map< uint32, std::vector<uint32> > &time_out_map = theMarketDC.db().down_map[sid];
    for( std::map< uint32, std::vector<uint32> >::iterator iter = time_out_map.begin();
        iter != time_out_map.end();
        ++iter )
    {
        if ( iter->first > time_now )
            break;

        for( std::vector<uint32>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {

            uint32 cargo_id = *jter;

            std::map< uint32, SMarketSellCargo >::iterator kter = theMarketDC.db().data_map.find( cargo_id );
            if ( kter == theMarketDC.db().data_map.end() )
                continue;

            SMarketSellCargo &cargo = kter->second;

            uint32 rid = cargo.role_id;

            //回发协议
            PRMarketSellData msg;
            msg.role_id = rid;
            msg.set_type = kObjectDel;
            msg.data = cargo;

            social::write( SERVER_ID( rid ), msg );

            PRMarketCargoDown msg_down;
            msg_down.role_id = rid;
            msg_down.data = cargo;
            social::write( SERVER_ID( rid ), msg_down);

            //数据库修改
            modify_db_data( kObjectDel, cargo );

            //移除本地数据
            cargo_remove( cargo_id );
        }
        iter->second.clear();
    }

}

void sell_time_out( uint32 sid )
{
    if ( 0 == sid )
        return;

    std::vector< uint32 > &sell_list = theMarketDC.db().sell_map[sid];
    for( std::vector<uint32>::iterator iter = sell_list.begin();
        iter != sell_list.end();
        ++iter )
    {
        std::map< uint32, SMarketSellCargo >::iterator jter = theMarketDC.db().data_map.find( *iter );
        if ( jter == theMarketDC.db().data_map.end() )
            continue;

        SMarketSellCargo &cargo = jter->second;
        if ( 0 == cargo.money )
            continue;

        //向售卖方发送售出记录
        {
            PRMarketSellData rep;
            rep.role_id = cargo.role_id;

            if ( cargo.coin.val <= 0 )
                rep.set_type = kObjectDel;
            else
                rep.set_type = kObjectUpdate;

            rep.data = cargo;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        //向售卖方发送售出后数据记录
        {
            PRMarketSell rep;
            rep.role_id = cargo.role_id;

            rep.cargo_id = cargo.cargo_id;
            rep.name    = cargo.buy_name;
            rep.value   = cargo.money;
            rep.coin.cate   = cargo.coin.cate;
            rep.coin.objid  = cargo.coin.objid;
            rep.coin.val    = cargo.buy_count;

            social::write( SERVER_ID( cargo.role_id ), rep );
        }

        cargo.money = 0;
        cargo.buy_count = 0;

        //修改数据
        if ( cargo.coin.val <= 0 )
        {
            //数据库修改
            modify_db_data( kObjectDel, cargo );

            //移除本地数据
            cargo_remove( cargo.cargo_id );
        }
        else
        {
            //数据库修改
            modify_db_data( kObjectUpdate, cargo );
        }

    }
    sell_list.clear();
}

void sell_money( uint32 rid, uint32 cargo_id )
{
    if ( 0 == rid )
        return;

    std::map< uint32, SMarketSellCargo >::iterator iter = theMarketDC.db().data_map.find( cargo_id );
    if ( iter == theMarketDC.db().data_map.end() )
        return;

    SMarketSellCargo &cargo = iter->second;

    cargo.money = 0;

    std::vector<uint32> &list = theMarketDC.db().sell_map[SERVER_ID(rid)];
    std::vector<uint32>::iterator jter = std::find( list.begin(), list.end(), cargo_id );
    if ( jter != list.end() )
        list.erase(jter);

    //修改数据
    if ( cargo.coin.val <= 0 )
    {
        //数据库修改
        modify_db_data( kObjectDel, cargo );

        //移除本地数据
        cargo_remove( cargo_id );
    }
    else
    {
        //数据库修改
        modify_db_data( kObjectUpdate, cargo );
    }
}

#undef TYPE_LEVEL

} // namespace market

