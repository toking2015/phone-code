#include "rank_imp.h"
#include "proto/rank.h"
#include "rank_dc.h"
#include "server.h"
#include "rank_event.h"
#include "local.h"
#include "resource/r_rankcopyext.h"
#include "jsonconfig.h"
#include "systimemgr.h"
#include "util.h"
#include "log.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "equip_imp.h"
#include "temple_imp.h"

namespace rank
{

bool rank_compare_asc( const SRankInfo& l, const SRankInfo& r )
{
    if ( l.first < r.first )
        return true;
    if ( l.first > r.first )
        return false;
    if ( l.second < r.second )
        return true;
    if ( l.second > r.second )
        return false;
    return l.id < r.id;
}

bool rank_compare_desc( const SRankInfo& l, const SRankInfo& r )
{
    if ( l.first > r.first )
        return true;
    if ( l.first < r.first )
        return false;
    if ( l.second > r.second )
        return true;
    if ( l.second < r.second )
        return false;
    return l.id < r.id;
}

bool rank_compare_market( const SRankInfo& l, const SRankInfo& r )
{
    if ( l.first > r.first )
        return true;
    if ( l.first < r.first )
        return false;
    if ( l.second < r.second )
        return true;
    if ( l.second > r.second )
        return false;
    return l.id < r.id;
}

bool rank_limit_compare( const SRankInfo& l, const SRankInfo& r )
{
    return l.limit > r.limit;
}

//根据数据 id 获取排行榜位置
int32 rank_get_index( CRank& data, uint32 id )
{
    for ( std::vector< SRankInfo >::iterator iter = data.rank.begin();
        iter != data.rank.end();
        ++iter )
    {
        if ( iter->id == id )
            return iter - data.rank.begin();
    }

    return -1;
}

FRankCompare rank_compare_method( uint32 rank_type )
{
    std::map< uint32, FRankCompare >::iterator iter = rank_compare_map().find( rank_type );
    if ( iter == rank_compare_map().end() )
        return rank_compare_desc;

    return iter->second;
}

int32 rank_new_get_index( CRank& data, uint32 rank_type, uint32 id )
{
    std::map< uint32,SRankData >::iterator find_iter = data.id_data.find( id );
    if( find_iter == data.id_data.end() )
        return -1;

    FRankCompare compare = rank_compare_method( rank_type );

    //取得左值位置
    std::vector< SRankInfo >::iterator lower = std::lower_bound
        (
         data.rank.begin(),
         data.rank.end(),
         find_iter->second.info,
         compare
        );

    for ( std::vector< SRankInfo >::iterator iter = lower;
        iter != data.rank.end();
        ++iter )
    {
        if ( iter->id == id )
            return iter - data.rank.begin();
    }

    /**
    for ( std::vector< SRankInfo >::iterator iter = lower;
        iter != data.rank.begin();
        --iter )
    {
        ++count;
        if ( iter->id == id )
            return iter - data.rank.begin();
    }
    **/
    return -1;
}

S2UInt32 rank_get_limit_bound( CRank& data, uint32 limit )
{
    SRankInfo info;
    info.limit = limit;

    std::vector< SRankInfo >::iterator lower = std::lower_bound
        (
         data.rank.begin(),
         data.rank.end(),
         info,
         rank_limit_compare
        );

    std::vector< SRankInfo >::iterator upper = std::upper_bound
        (
         data.rank.begin(),
         data.rank.end(),
         info,
         rank_limit_compare
        );

    S2UInt32 bound;
    bound.first = lower - data.rank.begin();
    bound.second = upper - data.rank.begin();

    return bound;
}

void rank_update_data( uint32 rank_type, CRank& rank, SRankData& data, FRankCompare compare )
{
    //获取原有索引
    int32 index = rank_new_get_index( rank, rank_type, data.info.id );
    //int32 index = rank_get_index( rank, data.info.id );
    if ( index >= 0 )
    {
        rank.rank[ index ] = data.info;

        //左偏移
        for ( int32 i = index; i > 0; --i )
        {
            if ( !compare( rank.rank[ i ], rank.rank[ i - 1 ] ) )
                break;

            std::swap( rank.rank[ i ], rank.rank[ i - 1 ] );
        }

        //右偏移
        for ( int32 i = index; i < (int32)rank.rank.size() - 1; ++i )
        {
            if ( !compare( rank.rank[ i + 1 ], rank.rank[ i ] ) )
                break;

            std::swap( rank.rank[ i + 1 ], rank.rank[ i ] );
        }
    }
    else
    {
        //取得右值位置
        std::vector< SRankInfo >::iterator upper = std::upper_bound
            (
             rank.rank.begin(),
             rank.rank.end(),
             data.info,
             compare
            );

        //插入数据
        rank.rank.insert( upper, data.info );
    }

    std::map< uint32,SRankData >::iterator find_iter = rank.id_data.find( data.info.id );
    if( find_iter != rank.id_data.end() )
        data.info.index = find_iter->second.info.index;
    else if( rank_type == kRankingTypeMarket )
    {
        data.info.index = FindIndex( rank_type, data.info.id, kRankAttrCopy, data.info.limit ) + 1;
    }

    rank.id_data[ data.info.id ] = data;
}

void rank_delete_data( CRank& rank, uint32 rank_type, uint32 id )
{
    int32 index = rank_new_get_index( rank, rank_type, id );
    if ( index < 0 )
        return;

    rank.id_data.erase( id );
    rank.rank.erase( rank.rank.begin() + index );
}

std::map< uint32, FRankCompare >& rank_compare_map(void)
{
    static std::map< uint32, FRankCompare > map;
    return map;
}

void Register( uint32 rank_type, FRankCompare compare )
{
    rank_compare_map()[ rank_type ] = compare;
}


void ClearData( uint32 rank_type, uint32 attr )
{
    std::map< uint32, CRank >& rank_map = switch_rank_map( attr );

    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );
    if ( rank_iter != rank_map.end() )
    {
        CRank& rank = rank_iter->second;
        rank.id_data.clear();
        rank.rank.clear();
    }

    if ( attr == kRankAttrCopy )
        sync_copy_rank( rank_type );
}

void LoadData( uint32 rank_type, std::vector< SRankData >& list, uint32 attr )
{
    //LOG_DEBUG("LOadData start:%u",(uint32)server::local_time());
    FRankCompare compare = rank_compare_method( rank_type );

    std::map< uint32, CRank >& rank_map = switch_rank_map( attr );
    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );

    if ( rank_iter == rank_map.end() )
    {
        rank_map[ rank_type ] = CRank();

        rank_iter = rank_map.find( rank_type );

        if( rank_iter == rank_map.end() )
            return;
    }

    CRank& rank = rank_iter->second;

    //初始化完成
    if ( list.empty() )
    {
        //一定会先加载 kRankAttrReal, 所以 attr == kRankAttrCopy 并且没有数据时已经加载完成
        if ( attr == kRankAttrCopy )
        {
            //即时排行榜和记录排行榜数据准备完毕后尝试恢复丢失的记录排行
            //resume_rank_copy( rank_type );

            event::dispatch( SEventRankLoad( rank_type ) );


            InitCopyIndex( rank_type );
        }
        return;
    }

    for ( std::vector< SRankData >::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        rank_update_data( rank_type, rank, *iter, compare );
    }
    //LOG_DEBUG("LOadData end  :%u",(uint32)server::local_time());
}

void SetData( uint32 rank_type, SRankData& data )
{
    FRankCompare compare = rank_compare_method( rank_type );

    std::map< uint32, CRank >::iterator rank_iter = theRankDC.db().real_map.find( rank_type );
    if ( rank_iter == theRankDC.db().real_map.end() )
        return;

    rank_update_data( rank_type, rank_iter->second, data, compare );
}

void DelData( uint32 rank_type, uint32 id )
{
    std::map< uint32, CRank >::iterator rank_iter = theRankDC.db().real_map.find( rank_type );
    if ( rank_iter == theRankDC.db().real_map.end() )
        return;

    rank_delete_data( rank_iter->second, rank_type, id );
}

int32 FindIndex( uint32 rank_type, uint32 id, uint32 attr, uint32 limit )
{
    std::map< uint32, CRank >& rank_map = switch_rank_map( attr );

    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );
    if ( rank_iter == rank_map.end() )
        return -1;

    int32 index = rank_new_get_index( rank_iter->second, rank_type, id );
    if ( index < 0 )
        return -1;


    S2UInt32 bound = rank_get_limit_bound( rank_iter->second, limit );
    if ( bound.first >= bound.second )
        return -1;


    if ( index < (int32)bound.first || index >= (int32)bound.second )
        return -1;


    return index - (int32)bound.first;
}

uint32 GetCount( uint32 rank_type, uint32 attr, uint32 limit )
{
    std::map< uint32, CRank >& rank_map = switch_rank_map( attr );

    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );
    if ( rank_iter == rank_map.end() )
        return 0;

    S2UInt32 bound = rank_get_limit_bound( rank_iter->second, limit );
    if ( bound.first >= bound.second )
        return 0;

    return bound.second - bound.first;
}

uint32 GetRank( uint32 rank_type, uint32 index, uint32 count, uint32 attr, uint32 limit, std::vector< SRankData >& list )
{
    std::map< uint32, CRank >& rank_map = switch_rank_map( attr );

    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );
    if ( rank_iter == rank_map.end() )
        return 0;

    CRank& rank = rank_iter->second;

    S2UInt32 bound = rank_get_limit_bound( rank, limit );
    if ( bound.first >= bound.second )
        return 0;

    uint32 size = bound.second - bound.first;
    if ( index >= size )
        return size;

    for ( std::vector< SRankInfo >::iterator iter = rank.rank.begin() + bound.first + index;
        iter != rank.rank.begin() + bound.second && count > 0;
        ++iter, --count )
    {
        std::map< uint32, SRankData >::iterator find_iter = rank.id_data.find( iter->id );
        list.push_back( find_iter->second );
    }

    return size;
}

void GetData( uint32 rank_type, uint32 index, uint32 attr, uint32 limit, SRankData& data )
{
    std::map< uint32, CRank >& rank_map = switch_rank_map( attr );

    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );
    if ( rank_iter == rank_map.end() )
        return;

    CRank& rank = rank_iter->second;

    S2UInt32 bound = rank_get_limit_bound( rank, limit );
    if ( bound.first >= bound.second )
        return;

    uint32 size = bound.second - bound.first;
    if ( index >= size )
        return;

    for ( std::vector< SRankInfo >::iterator iter = rank.rank.begin() + bound.first + index;
        iter != rank.rank.begin() + bound.second;
        ++iter )
    {
        std::map< uint32, SRankData >::iterator find_iter = rank.id_data.find( iter->id );
        data = find_iter->second;
        return;
    }
}

void CopyRank( uint32 rank_type, uint32 day/* = 0*/ )
{
    //LOG_ERROR("CopyRank start rank_type:%d,day:%d",rank_type,day);

    theRankDC.db().copy_map[ rank_type ] = theRankDC.db().real_map[ rank_type ];

    //同步数据
    sync_copy_rank( rank_type );

    //保存记录日期
    std::stringstream stream;
    stream << "rank_copy_time_" << (uint32)rank_type;

    if ( day == 0 )
        day = server::local_time();

    server::set( stream.str(), day );

    //如果是拍卖行，清空实时数据  否:重置index
    if( rank_type == kRankingTypeMarket )
        ClearData( rank_type, kRankAttrReal );
    else
        InitCopyIndex( rank_type );


    //回调事件
    event::dispatch( SEventRankCopy( rank_type ) );
}

std::map< uint32, CRank >& switch_rank_map( uint32 attr )
{
    switch ( attr )
    {
    case kRankAttrReal:
        return theRankDC.db().real_map;

    case kRankAttrCopy:
        return theRankDC.db().copy_map;
    }

    return theRankDC.db().real_map;
}

void sync_copy_rank( uint32 rank_type )
{
    CRank& rank = theRankDC.db().copy_map[ rank_type ];

    //初始化协议包
    PQRankCopySave rep;
    rep.rank_type = rank_type;

    //发送删除协议
    rep.set_type = kRankingObjectDel;
    local::write( local::realdb, rep );

    //整合列表
    rep.set_type = kRankingObjectAdd;
    for ( std::map< uint32, SRankData >::iterator iter = rank.id_data.begin();
        iter != rank.id_data.end();
        ++iter )
    {
        rep.list.push_back( iter->second );
        if ( rep.list.size() >= 512 )
        {
            //发送增加协议
            local::write( local::realdb, rep );

            rep.list.clear();
        }
    }

    //发送剩余数据包
    if ( !rep.list.empty() )
        local::write( local::realdb, rep );
}

void InitCopyIndex( uint32 rank_type )
{
    std::map< uint32, CRank >& rank_map = switch_rank_map( kRankAttrReal );

    std::map< uint32, CRank >::iterator rank_iter = rank_map.find( rank_type );
    if ( rank_iter == rank_map.end() )
        return;

    CRank& rank = rank_iter->second;

    for ( std::vector< SRankInfo >::iterator iter = rank.rank.begin();
        iter != rank.rank.end();
        ++iter )
    {
        std::map< uint32, SRankData >::iterator find_iter = rank.id_data.find( iter->id );
        find_iter->second.info.index = FindIndex( rank_type, find_iter->second.info.id, kRankAttrCopy, find_iter->second.info.limit ) + 1;
    }
}

void UpdateSingleArena( uint32 target_id, uint16 avatar, std::string& name, uint32 level,  uint32 first )
{
    SRankData data;
    data.info.id            = target_id;
    data.info.avatar        = avatar;
    data.info.name          = name;
    data.info.team_level    = level;
    data.info.limit         = 10;
    data.info.first         = first;

    if( data.info.team_level < 10 )
        return;

    SetData( kRankingTypeSingleArena, data );
}


void QuerySingleArena( uint32 target_id, uint32 first, uint32 second, std::vector<uint32> &list )
{
    int32 index = FindIndex( kRankingTypeSingleArena, target_id, kRankAttrCopy, 10 );
    uint32 f_index = 0;

    std::vector< SRankData >  rank_list;
    if ( index >= 0 )
    {
        if( first > 0 && index > 0 )
        {
            if( (uint32)index > first )
                f_index = index - first;

            GetRank( kRankingTypeSingleArena, f_index, index - f_index , kRankAttrCopy, 10, rank_list );
        }

        if( second > 0 )
        {
            GetRank( kRankingTypeSingleArena, index + 1, second , kRankAttrCopy, 10, rank_list );
        }

    }
    else
    {
        uint32 query_count = first + second;
        uint32 max_count = GetCount( kRankingTypeSingleArena, kRankAttrCopy, 10 );
        f_index = max_count > query_count ? max_count - query_count : 0;

        GetRank( kRankingTypeSingleArena, f_index, query_count, kRankAttrCopy, 10, rank_list );

    }

    for( std::vector< SRankData >::iterator iter = rank_list.begin();
        iter != rank_list.end();
        ++iter )
    {
        list.push_back( iter->info.id );
    }
}

void UpdateSoldier( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    data.info.first         = soldier::GetSoldierCount( puser );
    data.info.second        = soldier::GetSoldierStar( puser );

    if( data.info.first > 0 )
        SetData( kRankingTypeSoldier, data );
}

void UpdateTotem( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    data.info.first         = (uint32)(puser->data.totem_map[kTotemPacketNormal].totem_list.size());
    data.info.second        = totem::GetTotemTotalLevel( puser );

    if( data.info.first > 0 )
        SetData( kRankingTypeTotem, data );
}

void UpdateCopy( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    data.info.first        = puser->data.star.copy;
    data.info.second       = (uint32)(puser->data.copy_log_map.size());

    if( data.info.first > 0 )
        SetData( kRankingTypeCopy, data );
}

void UpdateEquip( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    uint32 equip_type   = 0;
    uint32 equip_level  = 0;
    data.info.first             = equip::GetMaxGrade( puser, equip_type, equip_level );
    data.data["equip_type"]     = equip_type;
    data.data["equip_level"]    = equip_level;

    if( data.info.first > 0 )
        SetData( kRankingTypeEquip, data );
}

void UpdateMarket( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    uint32 get_money        = puser->data.other.market_day_get;
    //uint32 cost_money       = puser->data.other.market_day_cost;
    data.info.first         = get_money;// > cost_money ? get_money - cost_money : 0;
    data.info.second        = 0;//cost_money > get_money ? cost_money - get_money : 0;

    if( get_money > 0 )
        SetData( kRankingTypeMarket, data );
}

void UpdateTeamLevel( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    data.info.first         = data.info.team_level;
    data.info.second        = puser->data.star.copy;

    SetData( kRankingTypeTeamLevel, data );
}

void UpdateTemple( SUser* puser )
{
    SRankData data;
    if ( InitUpdateData( puser, data ) == false )
        return;

    data.info.first         = temple::GetScore( puser );
    data.info.second        = data.info.team_level;

    if( data.info.first > 0 )
        SetData( kRankingTypeTemple, data );
}

bool InitUpdateData( SUser* puser, SRankData& data )
{
    data.info.id            = puser->guid;
    data.info.avatar        = puser->data.simple.avatar;
    data.info.name          = puser->data.simple.name;
    data.info.team_level    = puser->data.simple.team_level;
    data.info.limit         = 10;

    if( data.info.team_level >= 10 )
        return true;

    return false;
}

} // namespace rank
