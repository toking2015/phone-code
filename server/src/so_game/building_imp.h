#ifndef _GAMESVR_BUILDINGLOGIC_H_
#define _GAMESVR_BUILDINGLOGIC_H_

#include "common.h"
#include "proto/common.h"
#include "proto/user.h"
#include "proto/building.h"
#include "dynamicmgr.h"
/*
 * 建筑功能:
 * 1.常规接口:      添加/升级
 * 2.仅服务端使用:
 */

#define MacroCheckBuildingGuid( tp, id )\
std::vector<SUserBuilding>::iterator iter = std::find_if(user->data.building_list.begin(), user->data.building_list.end(), Building_EqualBuildingId( tp, id ) );\
if ( user->data.building_list.end() == iter )\
{\
    return;\
}


#define MacroCheckBuildingType( tp)\
std::vector<SUserBuilding>::iterator iter = std::find_if(user->data.building_list.begin(), user->data.building_list.end(), Building_EqualBuildingType( tp ) );\
if ( user->data.building_list.end() == iter )\
{\
    return;\
}

#define MacroCheckBuildingTypeReturn( tp)\
std::vector<SUserBuilding>::iterator iter = std::find_if(user->data.building_list.begin(), user->data.building_list.end(), Building_EqualBuildingType( tp ) );\
if ( user->data.building_list.end() == iter )\
{\
    return 0;\
}

namespace building
{
    /**************通用接口***************/

    //返回建筑更新
    void ReplyBuildingSet( SUser *user, SUserBuilding& building, uint8 set_type );

    //得到目标某类建筑的下一个 guid
    uint32 GetGuid( SUser *user, uint8 building_type );

    //得到目标某类建筑的数量
    uint32 GetCount( SUser *user, uint8 building_type );

    //返回建筑群
    void ReplyBuildingList( SUser *user, uint32 target_id );

    //添加建筑
    void CreateBuilding( SUser *user, uint8 building_type, S2UInt32 position );

    //升级建筑  building_id = 0 时，为升级所有此类型的建筑
    void UpgradeBuilding( SUser *user, uint8 building_type, uint32 building_id );

    //称动建筑
    void MoveBuilding( SUser *user, uint8 building_type, uint32 building_id, S2UInt32 position );

    //查询建筑
    void QueryBuilding( SUser *user, uint32 target_id, uint8 building_type, uint32 building_id );

    //查看  最大值
    uint32 GetMaxValue( SUser *user, uint8 building_type );
    //设置  最大值
    uint32 SetMaxValue( SUser *user, uint8 building_type );

    //查看  当前值
    uint32 GetValue( SUser *user, uint8 building_type );

    //查看  容量
    uint32 GetSpace( SUser *user, uint8 building_type );

    //增加
    uint32 AddValue( SUser *user, uint8 building_type, uint32 value, uint32 path );

    //消耗
    void TakeValue( SUser *user, uint8 building_type, uint32 value, uint32 path );


    /********针对性接口****************/
    //计算金矿的产出
    void CalculateOutput( SUser *user, uint8 building_type );
    //金矿加速产出
    void SpeedOutput( SUser *user, uint8 building_type, uint8 count );

    //建筑升级时，领取满产出
    void TakeReward( SUser *user, uint8 building_type );

    //计算暴击率
    uint32 GetRand(std::vector< S2UInt32 > &list );

    void    TimeLimit( SUser* puser );

}// namespace building

#endif
