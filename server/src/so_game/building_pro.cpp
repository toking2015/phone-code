#include "misc.h"
#include "building_imp.h"
#include "building_event.h"
#include "coin_imp.h"
#include "netsingle.h"
#include "proto/building.h"
#include "user_dc.h"
#include "event.h"
#include "log.h"

/*****************建筑协议请求*****************/
//请求建筑列表
MSG_FUNC( PQBuildingList )
{
    QU_ON( user, msg.role_id );

    //限制，不能申请其它玩家的建筑列表
    if( user->guid != msg.target_id )
        return;

    building::ReplyBuildingList( user, msg.target_id );
}

MSG_FUNC( PQBuildingAdd )
{
    QU_ON( user, msg.role_id );

    building::CreateBuilding( user, msg.building_type, msg.building_position );
}

MSG_FUNC( PQBuildingUpgrade )
{
    QU_ON( user, msg.role_id );

    building::UpgradeBuilding( user, msg.building_type, msg.building_id );
}

//不实现了
MSG_FUNC( PQBuildingMove )
{
    QU_ON( user, msg.role_id );

    //building::MoveBuilding( user, msg.building_type, msg.building_id, msg.building_position );
}

//不实现了
MSG_FUNC( PQBuildingQuery )
{
    QU_ON( user, msg.role_id );

    //building::QueryBuilding( user, msg.target_id, msg.building_type, msg.building_id );

}

/*********针对性协议**********/

//领取建筑的产出
MSG_FUNC( PQBuildingGetOutput )
{
    QU_ON( user, msg.role_id );

    //先计算产出
    building::CalculateOutput( user, msg.building_type );

    //消耗产出
    uint32 value = building::GetValue( user, msg.building_type );
    building::TakeValue( user, msg.building_type, value, kPathBuildingGetOutput );

    //把产出转换为最终货币
    uint32  coin_cate = kCoinMoney;
    switch( msg.building_type )
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
    add_coin.val  = value;
    coin::give( user, add_coin, kPathBuildingGetOutput );

    //领取建筑资源
    event::dispatch( SEventBuildingResourceTake( user, kPathBuildingGetOutput, msg.building_type, value ) );
}

//加速建筑的产出
MSG_FUNC( PQBuildingSpeedOutput )
{
    QU_ON( user, msg.role_id );

    building::SpeedOutput( user, msg.building_type, msg.times );
}
/*****************建筑协议回复*****************/

