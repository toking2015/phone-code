#include "building_imp.h"
#include "team_event.h"
#include "user_event.h"
#include "copy_event.h"
#include "task_event.h"
#include "dc.h"
#include "resource/r_globalext.h"
#include "resource/r_buildingext.h"
#include "log.h"

struct building_check_open
{
    SUser *pUser;
    building_check_open( SUser* u){ pUser = u;}
    bool operator()( std::pair< const uint32, CBuildingData::SData* >& pair )
    {
        CBuildingData::SData*  pData = pair.second;

        if( !pData )
            return true;

        if( !pUser )
            return true;

        uint32 team_level = pUser->data.simple.team_level;

        if ( pData->common_open > team_level )
            return true;

        //检查已完成副本
        if ( pData->copy_open > 0 && !dc::map_has_key( pUser->data.copy_log_map, pData->copy_open ) )
            return true;

        //检查已存在任务
        if ( pData->task_open > 0 && !dc::map_has_key( pUser->data.task_map, pData->task_open ) )
        {
            if( !dc::map_has_key( pUser->data.task_log_map, pData->task_open ) )
                return true;
        }


        if ( building::GetCount( pUser, pData->id ) == 0 )
        {
            S2UInt32 position;
            position.first  = 10;
            position.second = 10;
            building::CreateBuilding( pUser, pData->id, position );
        }

        return true;
    }
};

struct building_check_copy_open
{
    SUser *pUser;
    uint32 copy_id;
    building_check_copy_open( SUser* u, uint32 id) : copy_id(id){ pUser = u;}
    bool operator()( std::pair< const uint32, CBuildingData::SData* >& pair )
    {
        CBuildingData::SData*  pData = pair.second;

        if( !pData )
            return true;

        if( !pUser )
            return true;

        if ( pData->common_open > 0  || pData->copy_open != copy_id )
            return true;

        if ( building::GetCount( pUser, pData->id ) == 0 )
        {
            S2UInt32 position;
            position.first  = 10;
            position.second = 10;
            building::CreateBuilding( pUser, pData->id, position );
        }

        return true;
    }
};

struct building_upgrade
{
    SUser *pUser;
    building_upgrade( SUser* u) { pUser = u;}
    bool operator()( std::pair< const uint32, CBuildingData::SData* >& pair )
    {
        CBuildingData::SData*  pData = pair.second;

        if( !pData )
            return true;

        if( !pUser )
            return true;

        building::UpgradeBuilding( pUser, pData->id, 0 );

        return true;
    }
};

EVENT_FUNC( building, SEventTeamLevelUp )
{
    //战队等级提升，自动提升金矿等级
    //building::UpgradeBuilding( ev.user, kBuildingTypeGoldField, 0 );
    //building::UpgradeBuilding( ev.user, kBuildingTypeWaterFactory, 0 );

    theBuildingExt.Each( building_check_open( ev.user ) );
    theBuildingExt.Each( building_upgrade( ev.user ) );
}

EVENT_FUNC( building, SEventUserInit )
{
    theBuildingExt.Each( building_check_open( ev.user ) );
}

EVENT_FUNC( building, SEventUserLoaded )
{
    //玩家进入游戏时，检测是否有建筑可开放(兼容开服后，新增建筑)
    theBuildingExt.Each( building_check_open( ev.user ) );
    //theBuildingExt.Each( building_check_common_open( ev.user ) );
}

//完成对应的副本，可开放相应的建筑
EVENT_FUNC( building, SEventCopyFinished )
{
    theBuildingExt.Each( building_check_open( ev.user ) );
    //theBuildingExt.Each( building_check_copy_open( ev.user, ev.copy_id ) );
}

EVENT_FUNC( building, SEventTaskAccept )
{
    theBuildingExt.Each( building_check_open( ev.user ) );
}

EVENT_FUNC( building, SEventUserTimeLimit )
{
    building::TimeLimit( ev.user );
}

