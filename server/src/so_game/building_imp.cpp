#include "building_imp.h"
#include "building_event.h"
#include "coin_imp.h"
#include "var_imp.h"
#include "misc.h"
#include "local.h"
#include "netsingle.h"
#include "resource/r_buildingext.h"
#include "resource/r_buildingupgradeext.h"
#include "resource/r_buildingspeedext.h"
#include "resource/r_buildingcostext.h"
#include "resource/r_buildingcoinext.h"
#include "resource/r_buildingcrittimesext.h"
#include "resource/r_levelext.h"
#include "proto/building.h"
#include "proto/team.h"
#include "proto/constant.h"
#include "pro.h"
#include "log.h"
#include "user_dc.h"
#include "server.h"
#include "coin_event.h"
#include "dc.h"


#define    MAX_BUILDING_VALUE    200000000

/*****************BEGIN-Functor********************/
struct Building_EqualBuildingId
{
    uint8  info_type;
    uint32 info_id;
    Building_EqualBuildingId(uint8 tp, uint32 id): info_type(tp), info_id( id ) { }
    bool operator () (const SUserBuilding building )
    {
        return building.data.info_id == info_id && building.data.info_type == info_type;
    }
};

struct Building_EqualBuildingType
{
    uint8  info_type;
    Building_EqualBuildingType(uint8 tp ): info_type(tp){ }
    bool operator () (const SUserBuilding building )
    {
        return building.data.info_type == info_type;
    }
};

namespace  building
{
    void ReplyBuildingSet( SUser *user, SUserBuilding& building, uint8 set_type )
    {
        PRBuildingSet rep;
        bccopy( rep, user->ext );

        rep.set_type = set_type;
        rep.building = building;

        local::write( local::access, rep );

    }

    //得到目标某类建筑的下一个 guid
    uint32 GetGuid( SUser *user, uint8 building_type )
    {
        uint32 guid = 1;
        for( std::vector< SUserBuilding > ::iterator iter = user->data.building_list.begin();
            iter != user->data.building_list.end();
            ++iter)
        {
            if( iter->data.info_type == building_type && iter->data.info_id == guid )
                ++guid;
        }

        return guid;
    }

    //得到目标某类建筑的数量
    uint32 GetCount( SUser *user, uint8 building_type )
    {
        uint32 count = 0;
        for( std::vector< SUserBuilding > ::iterator iter = user->data.building_list.begin();
            iter != user->data.building_list.end();
            ++iter)
        {
            if( iter->data.info_type == building_type )
                ++count;
        }

        return count;
    }

    //目标只申请在线的，后期应该会加入 QU_ALL( 先申请在线，没有，再申请离线 )
    void ReplyBuildingList( SUser *user, uint32 target_id )
    {
        QU_ON( target_user, target_id );

        PRBuildingList rep;
        bccopy( rep, user->ext );

        rep.list  = target_user->data.building_list;

        local::write( local::access, rep );
    }

    void CreateBuilding( SUser *user, uint8 building_type, S2UInt32 position )
    {
        CBuildingData::SData *data = theBuildingExt.Find( building_type );

        if ( data == NULL )
        {
            HandleErrCode(user, kErrBuildingDataNotExist, 0);
            return;
        }

        std::vector<SUserBuilding>::iterator iter = std::find_if(user->data.building_list.begin(), user->data.building_list.end(), Building_EqualBuildingType( building_type ) );

        //所有的建筑物，限制一个
        if ( user->data.building_list.end() != iter )
        {
            HandleErrCode(user, kErrBuildingCountNotMax, 0);
            return;
        }

        SUserBuilding sbuilding;
        sbuilding.building_guid      = GetGuid( user, building_type );
        sbuilding.building_type      = building_type;

        sbuilding.data.target_id     = user->guid;
        sbuilding.data.info_id       = sbuilding.building_guid;
        sbuilding.data.info_type     = building_type;
        sbuilding.data.info_level    = 1;
        sbuilding.data.info_position = position;

        sbuilding.ext.production     = 0;
        sbuilding.ext.time_point     = (uint32)server::local_time();

        user->data.building_list.push_back( sbuilding );

        sbuilding.ext.production = SetMaxValue( user, building_type );

        ReplyBuildingSet( user, sbuilding, kObjectAdd );
    }

    //暂时没有实现building_id
    void UpgradeBuilding( SUser *user, uint8 building_type, uint32 building_id )
    {
        MacroCheckBuildingType( building_type )

        uint32 curr_level = iter->data.info_level;


        //判断此建筑是否可能升级
        CBuildingData::SData *pData = theBuildingExt.Find( building_type );
        if ( NULL == pData )
            return;

        if ( pData->upgrade == 0 )
            return;


        CBuildingUpgradeData::SData *data = theBuildingUpgradeExt.Find( building_type, curr_level + 1);

        if ( NULL == data )
            return;

        //如果战队等级没达到
        if( user->data.simple.team_level < data->u_level )
            return;

        /**   其它条件，后期实现
        //主城
        std::vector<SUserBuilding>::iterator f_iter = std::find_if(user->data.building_list.begin(), user->data.building_list.end(), Building_EqualBuildingType( kBuildingTypeMajor ) )
        if ( user->data.building_list.end() == f_iter )
            return;

        if ( f_iter->info_level < data->f_level_[ building_type - 1 ] )
            return;

            **/

        building::TakeReward( user, building_type );

        iter->data.info_level += 1;
        ReplyBuildingSet( user, *iter, kObjectUpdate );
    }

    void MoveBuilding( SUser *user, uint8 building_type, uint32 building_id, S2UInt32 position )
    {
        MacroCheckBuildingType( building_type )

        iter->data.info_position = position;

        ReplyBuildingSet( user, *iter, kObjectUpdate );
    }

    void QueryBuilding( SUser *user, uint32 target_id, uint8 building_type, uint32 building_id )
    {
        QU_ON( target_user, target_id );

        MacroCheckBuildingGuid( building_type, building_id )

        PRBuildingQuery rep;
        bccopy( rep, user->ext );

        rep.target_id = target_id;
        rep.data      = *iter;

        local::write( local::access, rep );
    }

    uint32 GetValue( SUser *user, uint8 building_type )
    {
        std::vector<SUserBuilding>::iterator iter = std::find_if(user->data.building_list.begin(), user->data.building_list.end(), Building_EqualBuildingType( building_type ) );

        if ( user->data.building_list.end() == iter )
        {
            return 0;
        }

        return iter->ext.production;
    }

    uint32 AddValue( SUser *user, uint8 building_type, uint32 value, uint32 path )
    {
        MacroCheckBuildingTypeReturn( building_type )

        uint32 old_count = iter->ext.production;
        uint32 now_count = iter->ext.production;
        uint32 max_value = GetMaxValue( user, building_type );


        if ( old_count + value > max_value )
            now_count = max_value;
        else
            now_count += value;

        iter->ext.production = now_count;

        return max_value - now_count;
    }

    uint32 GetSpace( SUser *user, uint8 building_type )
    {
        MacroCheckBuildingTypeReturn( building_type )

        uint32 max_value = GetMaxValue( user, building_type );

        //正常情况不会出现，只有在静态资源出错的情况下
        if ( max_value == 0 )
            return 0;

        return max_value - iter->ext.production;
    }

    void TakeValue( SUser *user, uint8 building_type, uint32 value, uint32 path )
    {
        MacroCheckBuildingType( building_type )

        iter->ext.production = iter->ext.production > value ? iter->ext.production - value : 0;

        ReplyBuildingSet( user, *iter, kObjectUpdate );
    }

    uint32 GetMaxValue( SUser *user, uint8 building_type )
    {
        MacroCheckBuildingTypeReturn( building_type )

        uint32 max_value = MAX_BUILDING_VALUE;

        CBuildingSpeedData::SData *pData = theBuildingSpeedExt.Find( iter->data.info_level );
        if( NULL == pData )
            return 0;

        switch( building_type )
        {
        case kBuildingTypeGoldField:
            {
                max_value = pData->speed2 * 8 * 60;
            }
            break;
        case kBuildingTypeWaterFactory:
            {
                max_value = pData->speed6 * 8 * 60;
            }
            break;
        }

        return max_value;
    }

    uint32 SetMaxValue( SUser *user, uint8 building_type )
    {
        MacroCheckBuildingTypeReturn( building_type )

        if( building_type != kBuildingTypeGoldField && building_type != kBuildingTypeWaterFactory )
            return 0;

        iter->ext.production     = GetMaxValue( user,building_type );
        return iter->ext.production;
    }

    /********************针对性接口************************************/
    void CalculateOutput( SUser *user, uint8 building_type )
    {
        MacroCheckBuildingType( building_type )

        uint32 time_now  = (uint32)server::local_time();
        uint32 old_count = iter->ext.production;
        uint32 speed     = 1;

        CBuildingSpeedData::SData *pData = theBuildingSpeedExt.Find( iter->data.info_level );

        if( NULL == pData )
            return;

        switch( building_type )
        {
        case kBuildingTypeGoldField:
            {
                speed = pData->speed2;
            }
            break;
        case kBuildingTypeWaterFactory:
            {
                speed = pData->speed6;
            }
            break;
        default:
            return;
        }


        if ( old_count >  ( speed * 8 * 60 ) )
        {
            //设置产出资源转换为最终产物的时间点
            iter->ext.time_point = time_now;
            return;
        }


        uint32 add_time = ( time_now - iter->ext.time_point ) / 60;

        uint32 max_value = speed * 8 * 60 ;
        uint32 max_time  = 8 * 60;

        if ( add_time >= max_time )
            building::AddValue( user, building_type, max_value - old_count, 0 );
        else
            building::AddValue( user, building_type, add_time * speed, 0 );

        //设置产出资源转换为最终产物的时间点
        iter->ext.time_point = time_now;
    }

    void SpeedOutput( SUser *user, uint8 building_type, uint8 count )
    {
        //战队等级少于20级不开放
        if ( user->data.simple.team_level < 20 )
            return;

        //加速次数只能是 1 或 10
        if ( count != 1 && count != 10 )
            return;

        MacroCheckBuildingType( building_type )

        uint32 max_times = 0;
        std::string string_time = "";
        uint32 cur_times  = 0;
        uint32 add_value  = 0;
        uint32 coin_cate  = kCoinMoney;

        uint32 crit_times = 1;     //暴击倍数,1为没有暴击

        std::vector< S2UInt32 > list = theBuildingCritTimesExt.FindList( building_type );

        std::vector< uint32 > list_crit_times;
        list_crit_times.clear();

        S3UInt32 take_coin;
        take_coin.cate = kCoinGold;
        take_coin.val  = 0;

        uint32 cost_count = 0;

        CLevelData::SData *pLevelData = theLevelExt.Find( user->data.simple.vip_level );
        if( NULL == pLevelData )
            return;

        CBuildingCoinData::SData *pCoinData = theBuildingCoinExt.Find( building_type );
        if( NULL == pCoinData )
            return;

        if( (uint32)pCoinData->value.size() <= 0 )
            return;

        //设置产出类型
        coin_cate = pCoinData->value[ 0 ].cate;

        CBuildingCostData::SData *pCostData = NULL;

        switch( building_type )
        {
        case kBuildingTypeGoldField:
            {
                string_time = "building_goldfiel_speed_time";
                cur_times = var::get( user, string_time );
                max_times = pLevelData->building_gold_times > theBuildingCostExt.GetMaxTimes() ? theBuildingCostExt.GetMaxTimes() : pLevelData->building_gold_times;
                count =  ( count > max_times - cur_times )? ( max_times - cur_times ):count;
            }
            break;
        case kBuildingTypeWaterFactory:
            {
                string_time = "building_waterfactory_speed_time";
                cur_times = var::get( user, string_time );
                max_times = pLevelData->building_water_times   > theBuildingCostExt.GetMaxTimes() ? theBuildingCostExt.GetMaxTimes() : pLevelData->building_water_times;
                count =  ( count > max_times - cur_times )? ( max_times - cur_times ):count;
            }
            break;
        default:
            return;
        }

        //处理加速
        for( uint32 i = 1; i <= count; ++i )
        {
            pCostData = theBuildingCostExt.Find( cur_times + i );

            if ( pCostData && iter->data.info_level < (uint32)pCoinData->value.size() )
            {
                crit_times = 1;
                //crit_times = GetRand( list );

                take_coin = pCostData->cost6;

                if ( coin::check_take( user, take_coin ) == take_coin.cate )
                    break;
                else
                {
                    list_crit_times.push_back( crit_times );

                    add_value  += pCoinData->value[ iter->data.info_level - 1 ].val * crit_times;

                    //扣花费
                    coin::take( user,take_coin, kPathBuildingSpeedOutput );
                }
                //记录一次加速成功
                ++cost_count;
                //take_value += data->cost;
            }
        }

        /**
        //如果钱不够，就直接返回 PS:如果加速10次，但只有9次的钱，也是一次都不能加速
        if ( coin::check_give( user, take_coin ) == 0 )
            return;

        //扣钻石
        coin::take( user,take_coin, kPathBuildingSpeedOutput );
        **/

        //一次加速都没有成功
        if ( cost_count == 0 )
        {
            HandleErrCode(user, kErrBuildingSpeedError, 0);
            return;
        }

        //加金币
        S3UInt32 add_coin;
        add_coin.cate = coin_cate;
        add_coin.val  = add_value;
        coin::give( user, add_coin, kPathBuildingSpeedOutput );

        //设置当天的加速次数
        var::set( user, string_time, cur_times + cost_count, (uint32)server::local_6_time( 0, 1 ) );

        PRBuildingSpeedOutput rep;
        bccopy( rep, user->ext );

        rep.building_type       = building_type;
        rep.list_crit_times     = list_crit_times;
        rep.add_value           = add_value;

        local::write( local::access, rep );

        event::dispatch( SEventBuildingSpeedOutput( user, kPathBuildingSpeedOutput, building_type ) );
    }

    void TakeReward( SUser *user, uint8 building_type )
    {
        MacroCheckBuildingType( building_type )

        uint32 time_now  = (uint32)server::local_time();

        uint32 max_value = building::GetMaxValue( user, building_type );
        iter->ext.production = 0;
        iter->ext.time_point = time_now;


        uint32  coin_cate = kCoinMoney;
        switch( building_type )
        {
        case kBuildingTypeGoldField:
            {
                coin_cate = kCoinMoney;
            }
            break;
        case kBuildingTypeWaterFactory:
            {
                coin_cate = kCoinWater;
            }
            break;
        default:
            return;
        }

        S3UInt32 add_coin;
        add_coin.cate = coin_cate;
        add_coin.val  = max_value;
        coin::give( user, add_coin, kPathBuildingLeveUp );
    }

    uint32 GetRand(std::vector< S2UInt32 > &list )
    {
        uint32 rand_value = TRand( 0,10000 );
        uint32 crit_times = 1;

        for( std::vector< S2UInt32 >::iterator iter = list.begin();
            iter != list.end();
            ++iter )
        {
            if ( rand_value < iter->first )
                return iter->second;

            rand_value -= iter->first;
        }


        return crit_times;
    }

    void    TimeLimit( SUser* puser )
    {
        //清除每天金矿加速次数
        var::set( puser, "building_goldfiel_speed_time", 0);

        //清除每天太阳井加速次数
        var::set( puser, "building_waterfactory_speed_time", 0);

    }

}// namespace building

