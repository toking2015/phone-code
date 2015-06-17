#include "local.h"
#include "fight_imp.h"
#include "proto/constant.h"
#include "misc.h"
#include "resource/r_monsterext.h"
#include "resource/r_monsterfightconfext.h"
#include "resource/r_soldierext.h"
#include "resource/r_oddext.h"
#include "luamgr.h"
#include "luaseq.h"

namespace fight
{

void SetOrderLua( SFight *psfight,  std::vector<SFightOrder> &order_list )
{
    luaseq::call(theLuaMgr.Lua(), "theFightList.addOrder")( psfight->fight_id, order_list);
}

std::vector<SFightOrder> GetOrderLua( uint32 fight_id )
{
    return luaseq::call< std::vector<SFightOrder> >(theLuaMgr.Lua(), "theFightList.getOrderList")( fight_id );
}

void SetSoldierEndLua( SFight *psfight, std::vector<SFightPlayerSimple> &play_info_list )
{
    luaseq::call(theLuaMgr.Lua(), "theFightList.addEndSoldier")(psfight->fight_id, play_info_list);
}

void InitFightLua( uint32 fight_id, uint32 fight_seed, uint32 fight_type, std::vector<SFightPlayerInfo> &play_info_list )
{
    SInteger seed;
    seed.value = fight_seed;
    luaseq::call(theLuaMgr.Lua(),"theFightList.initFight")( fight_id, seed);
    luaseq::call(theLuaMgr.Lua(),"theFightList.setFightType")( fight_id, fight_type);
    FightInfoToLua( fight_id, play_info_list );
}

void FightInfoToLua( uint32 fight_id, std::vector<SFightPlayerInfo> &play_info_list )
{
    for ( std::vector< SFightPlayerInfo >::iterator iter = play_info_list.begin();
        iter != play_info_list.end();
        ++iter )
    {
        luaseq::call(theLuaMgr.Lua(), "theFightList.addFightUser")(fight_id, *iter);
    }
    return;
}


uint32 CheckFightLua( SFight *psfight, std::vector<SFightOrder> &order_list, std::vector<SFightPlayerSimple> &play_info_list )
{
    SetOrderLua(psfight, order_list);
    SetSoldierEndLua(psfight, play_info_list);
    return luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.checkServer")(psfight->fight_id);
}

void FightLua( uint32 fight_id, uint32 random_seed, uint32 fight_type, std::vector<SFightPlayerInfo> &play_info_list )
{
    InitFightLua( fight_id, random_seed, fight_type, play_info_list );
    luaseq::call(theLuaMgr.Lua(),"theFightList.autoFight")(fight_id);
}

uint32 GetWinCamp( uint32 fight_id )
{
    return luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.getWinCamp")(fight_id);
}

uint32 GetRoundOut( uint32 fight_id )
{
    return luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.getRoundOut")(fight_id);
}

std::map<uint32, SFightEndInfo> GetFightEndInfo( uint32 fight_id )
{
    return luaseq::call<std::map<uint32,SFightEndInfo> >(theLuaMgr.Lua(),"theFightList.getFightEndInfo")(fight_id);
}

void DelFight( uint32 fight_id )
{
    luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.delFight")(fight_id );
}

void TestFightLua()
{
    LOG_DEBUG("first");
    luaseq::call(theLuaMgr.Lua(), "theFightList.TestLua")();
    LOG_DEBUG("second");
}

}// namespace fight

