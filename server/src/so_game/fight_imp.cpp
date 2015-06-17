#include "local.h"
#include "fight_imp.h"
#include "proto/constant.h"
#include "misc.h"
#include "fightextable_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "resource/r_monsterext.h"
#include "resource/r_monsterfightconfext.h"
#include "resource/r_soldierext.h"
#include "resource/r_soldierextext.h"
#include "resource/r_oddext.h"
#include "resource/r_totemextext.h"
#include "resource/r_totemext.h"
#include "luamgr.h"
#include "luaseq.h"
#include "user_dc.h"
#include "jsonconfig.h"
#include "timer.h"
#include "server.h"

namespace fight
{

std::map< uint32, CFight* >& map(void)
{
    static std::map< uint32, CFight* > map;

    return map;
}

void SetSoldier( SUser *puser, SUserFormation &formation, SFightSoldier& fight_soldier )
{
    fight_soldier.fight_index = formation.formation_index;
    if ( kAttrSoldier == formation.attr )
    {
        SUserSoldier soldier;
        if ( !soldier::GetSoldier(puser, formation.guid,soldier) )
            return;
        CSoldierData::SData *psoldier = theSoldierExt.Find( soldier.soldier_id );
        if ( NULL == psoldier )
            return;
        fight_soldier.name = psoldier->name;
        fight_soldier.occupation = psoldier->occupation;
        fight_soldier.quality = soldier.quality;
        fight_soldier.attr = kAttrSoldier;
        fight_soldier.soldier_id = soldier.soldier_id;
        fight_soldier.soldier_guid = formation.guid;
        fight_soldier.level = soldier.level;
        fight_soldier.equip_type = psoldier->equip_type;
        fightextable::GetFightExtAble( puser, formation.guid, formation.attr, fight_soldier.fight_ext_able);

        soldier::GetSoldierSkill( puser, formation.guid, kSoldierTypeCommon, fight_soldier.skill_list );
        soldier::GetSoldierOdd( puser, formation.guid, kSoldierTypeCommon, fight_soldier.fight_index, fight_soldier.odd_list );
        fight_soldier.rage = soldier::GetSoldierRage( puser, formation.guid );
        fight_soldier.hp = fight_soldier.fight_ext_able.hp;
    }
    else if ( kAttrTotem == formation.attr )
    {
        totem::GetFightInfo(puser, kTotemPacketNormal, formation.guid, fight_soldier);
    }
}

void SetOrderLua( SFight *psfight,  std::vector<SFightOrder> &order_list )
{
    luaseq::call(theLuaMgr.Lua(), "theFightList.addOrder")( psfight->fight_id, order_list);
}

void SetSoldierEndLua( SFight *psfight, std::vector<SFightPlayerSimple> &play_info_list )
{
    psfight->soldierEndList = play_info_list;
    luaseq::call(theLuaMgr.Lua(), "theFightList.addEndSoldier")(psfight->fight_id, play_info_list);
}

void UpdateSoldierHpRage(SUser *puser, uint32 soldier_type, SFightPlayerSimple &play_info )
{
    for( std::vector<SFightSoldierSimple>::iterator jter = play_info.soldier_list.begin();
        jter != play_info.soldier_list.end();
        ++jter )
    {
        if ( (jter->attr == kAttrSoldier && play_info.attr == kAttrPlayer)
            || (jter->attr == kAttrMonster && play_info.attr == kAttrMonster) )
        {
            SUserSoldier soldier;
            if ( soldier::GetSoldier(puser, jter->soldier_guid, soldier, soldier_type ) )
            {
                soldier.hp = jter->hp;
                soldier.mp = jter->rage;
            }
            else if (soldier::GetSoldier(puser, jter->soldier_guid, soldier, kSoldierTypeCommon ) )
            {
                soldier.hp = jter->hp;
                soldier.mp = jter->rage;
            }
            else
            {
                soldier.hp = jter->hp;
                soldier.mp = jter->rage;
                soldier.guid = jter->soldier_guid;
            }
            puser->data.soldier_map[soldier_type][soldier.guid] = soldier;
        }
    }
}

uint32 GetDeadSoldierCount( SFight *psfight )
{
    if ( NULL == psfight )
        return ~0;

    uint32 count = 0;
    for( std::vector<SFightPlayerSimple>::iterator iter = psfight->soldierEndList.begin();
        iter != psfight->soldierEndList.end();
        ++iter )
    {
        if ( iter->camp != kFightLeft )
            continue;
        for( std::vector<SFightSoldierSimple>::iterator jter = iter->soldier_list.begin();
            jter != iter->soldier_list.end();
            ++jter )
        {
            if( jter->attr == kAttrTotem )
                continue;

            if( 0 == jter->hp )
                count++;
        }
    }
    return count;
}

void GetMonsterSkill( uint32 monster_id, std::vector<SFightSkill> &skill_list )
{
    CMonsterData::SData *pdata = theMonsterExt.Find( monster_id );
    if ( NULL == pdata )
        return;

    SFightSkill fight_skill;
    skill_list.clear();
    for( std::vector<S2UInt32>::iterator iter = pdata->skills.begin();
        iter != pdata->skills.end();
        ++iter )
    {
        if ( 0 == iter->first )
            continue;
        fight_skill.skill_id = iter->first;
        fight_skill.skill_level = iter->second;
        skill_list.push_back(fight_skill);
    }
}

void GetMonsterOdd( uint32 monster_id, uint32 monster_index, std::vector<SFightOdd> &odd_list )
{
    CMonsterData::SData *pdata = theMonsterExt.Find( monster_id );
    if ( NULL == pdata )
        return;

    SFightOdd fight_odd;
    odd_list.clear();
    for( std::vector<S2UInt32>::iterator iter = pdata->odds.begin();
        iter != pdata->odds.end();
        ++iter )
    {
        COddData::SData *podd = theOddExt.Find( iter->first, iter->second );
        if ( NULL == podd )
            continue;
        SFightOdd fight_odd;
        fight::CreateFightOdd(podd,fight_odd);
        odd_list.push_back(fight_odd);
    }
}

void GetMonsterSoldierSkill( uint32 id, std::vector<SFightSkill> &skill_list )
{
    CSoldierExtData::SData *pdata = theSoldierExtExt.Find( id );
    if ( NULL == pdata )
        return;

    SFightSkill fight_skill;
    skill_list.clear();
    for( std::vector<S2UInt32>::iterator iter = pdata->skills.begin();
        iter != pdata->skills.end();
        ++iter )
    {
        if ( 0 == iter->first )
            continue;
        fight_skill.skill_id = iter->first;
        fight_skill.skill_level = iter->second;
        skill_list.push_back(fight_skill);
    }
}

void GetMonsterSoldierOdd( uint32 id, uint32 monster_index, std::vector<SFightOdd> &odd_list )
{
    CSoldierExtData::SData *pdata = theSoldierExtExt.Find( id );
    if ( NULL == pdata )
        return;

    SFightOdd fight_odd;
    odd_list.clear();
    for( std::vector<S2UInt32>::iterator iter = pdata->odds.begin();
        iter != pdata->odds.end();
        ++iter )
    {
        COddData::SData *podd = theOddExt.Find( iter->first, iter->second );
        if ( NULL == podd )
            continue;
        SFightOdd fight_odd;
        fight::CreateFightOdd(podd, fight_odd);
        odd_list.push_back(fight_odd);
    }
}


void SetMonsterSoldier( uint32 id, SFightSoldier &fight_soldier, std::vector<SUserFormation> &formation_list )
{
    CSoldierExtData::SData  *pext_data = theSoldierExtExt.Find( id );
    if ( NULL == pext_data )
        return;
    CSoldierData::SData *psoldier_data = theSoldierExt.Find( pext_data->soldier_id );
    if ( NULL == psoldier_data )
        return;
    fight_soldier.soldier_id = pext_data->soldier_id;
    fight_soldier.attr = kAttrSoldier;
    fight_soldier.rage = pext_data->initial_rage;
    fight_soldier.occupation = psoldier_data->occupation;
    SoldierToFightExt(id, fight_soldier.fight_ext_able);
    GetMonsterSoldierSkill(id,fight_soldier.skill_list);
    GetMonsterSoldierOdd(id, fight_soldier.fight_index, fight_soldier.odd_list);
    fight_soldier.hp = fight_soldier.fight_ext_able.hp;
}

void SetTotem( uint32 id , SFightSoldier &fight_soldier )
{
    CTotemExtData::SData *pconf_data = theTotemExtExt.Find(id);
    if ( NULL == pconf_data )
        return;

    CTotemData::SData *ptotem_data = theTotemExt.Find(pconf_data->totem_id);
    if ( NULL == ptotem_data )
        return;
    fight_soldier.soldier_guid = id;
    //设置图腾属性
    totem::GetFightInfo(pconf_data->totem_id, pconf_data->level, pconf_data->wake_lv, pconf_data->speed_lv, pconf_data->formation_lv, fight_soldier);
}

void SetMonster( uint32 monster_id, SFightPlayerInfo &play_info, uint32 &guid )
{
    CMonsterFightConfData::SData *pdata = theMonsterFightConfExt.Find( monster_id );
    if ( NULL == pdata )
        return;

    for( std::vector<S2UInt32>::iterator iter = pdata->add.begin();
        iter != pdata->add.end();
        ++iter )
    {
        CMonsterData::SData *pmonster_data = theMonsterExt.Find(iter->first);
        if ( NULL == pmonster_data )
            continue;
        SFightSoldier fight_soldier;
        fight_soldier.guid = ++guid;
        fight_soldier.soldier_id = pmonster_data->id;
        fight_soldier.fight_index = iter->second;
        if ( !GetFightIndex(play_info, iter->second) )
            continue;
        fight_soldier.name = pmonster_data->name;
        fight_soldier.attr = kAttrMonster;
        fight_soldier.rage = pmonster_data->initial_rage;
        fight_soldier.occupation = pmonster_data->occupation;
        fight_soldier.level = pmonster_data->level;
        fight_soldier.equip_type = pmonster_data->equip_type;
        MonsterToFightExt(iter->first, fight_soldier.fight_ext_able);
        GetMonsterSkill(iter->first,fight_soldier.skill_list);
        GetMonsterOdd(iter->first, iter->second, fight_soldier.odd_list);
        fight_soldier.hp = fight_soldier.fight_ext_able.hp;

        play_info.soldier_list.push_back( fight_soldier );
    }

    for( std::vector<S2UInt32>::iterator iter = pdata->totemadd.begin();
        iter != pdata->totemadd.end();
        ++iter )
    {
        CTotemExtData::SData *pconf_data = theTotemExtExt.Find(iter->first);
        if ( NULL == pconf_data )
            continue;

        CTotemData::SData *ptotem_data = theTotemExt.Find(pconf_data->totem_id);
        if ( NULL == ptotem_data )
            continue;
        //设置图腾属性
        SFightSoldier fight_soldier;
        fight_soldier.guid = ++guid;
        fight_soldier.fight_index = iter->second;
        fight::SetTotem( iter->first, fight_soldier );
        play_info.soldier_list.push_back( fight_soldier );
        // TODO 给图腾自己
    }
}

bool GetFightIndex( SFightPlayerInfo &play_info, uint32 &index )
{
    std::vector<uint32> pos_list;
    pos_list.push_back(1);
    pos_list.push_back(4);
    pos_list.push_back(7);
    pos_list.push_back(2);
    pos_list.push_back(5);
    pos_list.push_back(8);
    std::map<uint32, bool> index_map;
    for( std::vector<SFightSoldier>::iterator iter = play_info.soldier_list.begin();
        iter != play_info.soldier_list.end();
        ++iter )
    {
        index_map[iter->fight_index] = true;
    }

    if ( index_map[index] )
    {
        for(std::vector<uint32>::iterator jter = pos_list.begin();
            jter != pos_list.end();
            ++jter )
        {
            if( !index_map[*jter] )
            {
                index = *jter;
                return false;
            }
        }
        return false;
    }
    return true;
}

void MonsterToFightExt( uint32 monster_id, SFightExtAble &able )
{
    CMonsterData::SData *pmonster_data = theMonsterExt.Find(monster_id);
    if ( NULL == pmonster_data )
        return;

    able.hp = pmonster_data->hp;
    able.physical_ack = pmonster_data->physical_ack;
    able.physical_def = pmonster_data->physical_def;
    able.magic_ack = pmonster_data->magic_ack;
    able.magic_def = pmonster_data->magic_def;
    able.speed = pmonster_data->speed;
    able.critper = pmonster_data->critper;
    able.critper_def = pmonster_data->critper_def;
    able.recover_critper = pmonster_data->recover_critper;
    able.recover_critper_def = pmonster_data->recover_critper_def;
    able.crithurt = pmonster_data->crithurt;
    able.crithurt_def = pmonster_data->crithurt_def;
    able.hitper = pmonster_data->hitper;
    able.dodgeper = pmonster_data->dodgeper;
    able.parryper = pmonster_data->parryper;
    able.parryper_dec = pmonster_data->parryper_dec;
    able.stun_def = pmonster_data->stun_def;
    able.silent_def = pmonster_data->silent_def;
    able.weak_def = pmonster_data->weak_def;
    able.fire_def = pmonster_data->fire_def;
    able.recover_add_fix = pmonster_data->recover_add_fix;
    able.recover_del_fix = pmonster_data->recover_del_fix;
    able.recover_add_per = pmonster_data->recover_add_per;
    able.recover_del_per = pmonster_data->recover_del_per;
    able.rage_add_fix = pmonster_data->rage_add_fix;
    able.rage_del_fix = pmonster_data->rage_del_fix;
    able.rage_add_per = pmonster_data->rage_add_per;
    able.rage_del_per = pmonster_data->rage_del_per;
    able.rage = 100;
}

void SoldierToFightExt( uint32 soldier_id, SFightExtAble &able )
{
    CSoldierExtData::SData *psoldier_data = theSoldierExtExt.Find(soldier_id);
    if ( NULL == psoldier_data )
        return;

    able.hp = psoldier_data->hp;
    able.physical_ack = psoldier_data->physical_ack;
    able.physical_def = psoldier_data->physical_def;
    able.magic_ack = psoldier_data->magic_ack;
    able.magic_def = psoldier_data->magic_def;
    able.speed = psoldier_data->speed;
    able.critper = psoldier_data->critper;
    able.critper_def = psoldier_data->critper_def;
    able.recover_critper = psoldier_data->recover_critper;
    able.recover_critper_def = psoldier_data->recover_critper_def;
    able.crithurt = psoldier_data->crithurt;
    able.crithurt_def = psoldier_data->crithurt_def;
    able.hitper = psoldier_data->hitper;
    able.dodgeper = psoldier_data->dodgeper;
    able.parryper = psoldier_data->parryper;
    able.parryper_dec = psoldier_data->parryper_dec;
    able.stun_def = psoldier_data->stun_def;
    able.silent_def = psoldier_data->silent_def;
    able.weak_def = psoldier_data->weak_def;
    able.fire_def = psoldier_data->fire_def;
    able.recover_add_fix = psoldier_data->recover_add_fix;
    able.recover_del_fix = psoldier_data->recover_del_fix;
    able.recover_add_per = psoldier_data->recover_add_per;
    able.recover_del_per = psoldier_data->recover_del_per;
    able.rage_add_fix = psoldier_data->rage_add_fix;
    able.rage_del_fix = psoldier_data->rage_del_fix;
    able.rage_add_per = psoldier_data->rage_add_per;
    able.rage_del_per = psoldier_data->rage_del_per;
    able.rage = 100;
}

void InitFightLua( SFight *psfight )
{
    if ( NULL == psfight )
        return;
    SInteger seed;
    seed.value = psfight->fight_randomseed;
    luaseq::call(theLuaMgr.Lua(),"theFightList.initFight")( psfight->fight_id, seed);
    luaseq::call(theLuaMgr.Lua(),"theFightList.setFightType")( psfight->fight_id, psfight->fight_type);
    FightInfoToLua( psfight );
}

void InitFightLua( SFight *psfight, uint32 _seed )
{
    if ( NULL == psfight )
        return;
    psfight->fight_randomseed = _seed;
    InitFightLua( psfight );
}

void FightInfoToLua( SFight *psfight )
{
    if ( NULL == psfight )
        return;

    for ( std::vector< SFightPlayerInfo >::iterator iter = psfight->fight_info_list.begin();
        iter != psfight->fight_info_list.end();
        ++iter )
    {
        PRFightRoundData rep;
        rep.fight_id = psfight->fight_id;
        rep.fightlog = luaseq::call<std::vector<SFightLog> >(theLuaMgr.Lua(), "theFightList.addFightUser")(psfight->fight_id, *iter);
        if ( psfight->fight_type != kFightTypeCopy )
            ReplyToAll( psfight->fight_id, rep );
    }
    return;
}

void AutoFight( SFight *psfight )
{
    InitFightLua( psfight );
    luaseq::call(theLuaMgr.Lua(),"theFightList.autoFight")(psfight->fight_id);
}

uint32 CheckFightLua( SFight *psfight, std::vector<SFightOrder> &order_list, std::vector<SFightPlayerSimple> &play_info_list )
{
    SetOrderLua(psfight, order_list);
    SetSoldierEndLua(psfight, play_info_list);
    {
        PQCommonFightClientEnd rep;
        rep.fight_info_game = *psfight;
        rep.order_list = order_list;
        rep.fight_info_list = play_info_list;
        local::write( local::fight, rep );
    }
    return luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.checkServer")(psfight->fight_id);
}

uint32 GetWinCamp( SFight *psfight )
{
    return luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.getWinCamp")(psfight->fight_id);
}

std::vector<SFightEndInfo> GetFightEndInfo( SFight *psfight )
{
    return luaseq::call<std::vector<SFightEndInfo> >(theLuaMgr.Lua(),"theFightList.getFightEndInfo")(psfight->fight_id);
}

uint32 GetRound( SFight *psfight )
{
    return luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.getRound")(psfight->fight_id);
}

void DelFight( SFight *psfight )
{
    luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.delFight")(psfight->fight_id );
}

void DelFight( uint32 id )
{
    SFight *psfight = theFightDC.find(id);
    if( NULL != psfight )
        luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.delFight")(psfight->fight_id );
}

void ReplyFightInfo( SFight *psfight )
{
    PRCommonFightInfo rep;
    rep.fight_id = psfight->fight_id;
    rep.fight_type = psfight->fight_type;
    rep.fight_randomseed = psfight->fight_randomseed;
    rep.fight_info_list = psfight->fight_info_list;

    for( std::vector<SFightPlayerInfo>::iterator iter = psfight->fight_info_list.begin();
        iter != psfight->fight_info_list.end();
        ++iter )
    {
        for( std::vector<SFightSoldier>::iterator jter = iter->soldier_list.begin();
            jter != iter->soldier_list.end();
            ++jter )
        {
            LOG_INFO("soldier_name:%s",jter->name.c_str());
        }
    }

    ReplyToAll( psfight->fight_id, rep );
}

void ReplyFightInfoToFightSvr( SFight *psfight )
{
    PRCommonFightInfo rep;
    rep.fight_id = psfight->fight_id;
    rep.fight_type = psfight->fight_type;
    rep.fight_randomseed = psfight->fight_randomseed;
    rep.fight_info_list = psfight->fight_info_list;

    SUser *puser = theUserDC.find( psfight->ack_id );
    if( NULL == puser )
        return;

    bccopy( rep, puser->ext );
    local::write( local::fight, rep );
}


void RoundSkill( uint32 id )
{
    SFight *psfight = theFightDC.find( id );
    if ( NULL == psfight )
        return;

    if ( luaseq::call<bool>(theLuaMgr.Lua(),"theFightList.checkEnd")(id) )
    {
        CFight *pcfight = Interface( psfight->fight_type );
        if ( NULL == pcfight )
            return;

        PRCommonFightClientEnd rep;
        rep.fight_id = id;
        rep.win_camp= luaseq::call<uint32>(theLuaMgr.Lua(),"theFightList.getWinCamp")(id);

        pcfight->OnFightClientEnd( psfight, rep.coins_list );
        ReplyToAll( id, rep );

        theFightDC.del(psfight->fight_id);
        DelFight( psfight );
    }
    else
    {
        PRFightRoundData rep;
        rep.fight_id = id;
        rep.fightlog = luaseq::call<std::vector<SFightLog> >(theLuaMgr.Lua(),"theFightList.roundSkill")(id);
        ReplyToAll( id, rep );


        psfight->seqno++;
        PRPlayerFightAck rep_ack;
        rep_ack.fight_id = id;
        rep_ack.seqno = psfight->seqno;
        rep_ack.skill_obj = luaseq::call<SFightSkillObject>(theLuaMgr.Lua(),"theFightList.roundSkillSoldier")(id);
        ReplyToAll( id, rep_ack );

        //添加Delay
        Json::Value json;
        json["fight_id"] = id;
        json["seqno"] = psfight->seqno;
        theSysTimeMgr.RemoveLoop( psfight->loop_id );
        psfight->loop_id = theSysTimeMgr.AddCall( "fight_delay_skill", CJson::Write(json), kFightDelayTime );
    }
}

void RoundDelaySkill( uint32 id, uint32 seqno )
{
    uint32 target_seqno = theFightDC.get_seqno( id );
    if ( seqno == target_seqno )
    {
        RoundSkill( id );
    }
}

void TotemSkill( uint32 id, uint32 guid )
{
    if ( luaseq::call<bool>(theLuaMgr.Lua(),"theFightList.checkTotemSkill")(id, guid) )
    {
        PRFightRoundData rep;
        rep.fight_id = id;
        rep.fightlog = luaseq::call<std::vector<SFightLog> >(theLuaMgr.Lua(),"theFightList.useTotemSkill")(id, guid);
        ReplyToAll( id, rep );
    }
}

CFight* Interface( uint32 fight_type )
{
    if ( map()[ fight_type ] == NULL )
    {
        switch( fight_type )
        {
        case kFightTypeCommon:
            map()[ fight_type ] = new CFight;
            break;
        case kFightTypeCopy:
            map()[ fight_type ] = new CFightCopy;
            break;
        case kFightTypeCommonPlayer:
            map()[ fight_type ] = new CFightPlayer;
            break;
        case kFightTypeFirstShow:
            map()[ fight_type ] = new CFightFirstShow;
            break;
        case kFightTypeSingleArenaMonster:
        case kFightTypeSingleArenaPlayer:
            map()[ fight_type ] = new CFightSingleArenaMonster;
            break;
        case kFightTypeTrialSurvival:
            map()[ fight_type ] = new CFightTrialSurvival;
            break;
        case kFightTypeTrialStrength:
            map()[ fight_type ] = new CFightTrialStrength;
            break;
        case kFightTypeTrialAgile:
            map()[ fight_type ] = new CFightTrialAgile;
            break;
        case kFightTypeTrialIntelligence:
            map()[ fight_type ] = new CFightTrialIntelligence;
            break;
        case kFightTypeTomb:
            map()[ fight_type ] = new CFightTomb;
            break;
        case kFightTypeFriend:
            map()[ fight_type ] = new CFightFriend;
            break;
        case kFightTypeCommonAuto:
            map()[ fight_type ] = new CFightAuto;
            break;
        default:
            break;
        }
    }

    return map()[ fight_type ];
}

void InitInterface()
{
    map().clear();
}

void GetFightData()
{
    std::map<uint32, CFightData> data = luaseq::call<std::map<uint32, CFightData> >(theLuaMgr.Lua(), "GetFightData")();
    theFightDC.set_fight_data( data );
}

void SetFightData()
{
    std::map<uint32, CFightData> data;
    theFightDC.get_fight_data( data );
    luaseq::call(theLuaMgr.Lua(),"SetFightData")(data);
}

void TestFightLua()
{
    luaseq::call(theLuaMgr.Lua(), "theFightList.TestLua")();
}

void RecordSave( SFight *psfight, std::vector<SFightOrder> &order_list )
{
    psfight->fight_record.fight_id = psfight->fight_id;
    psfight->fight_record.fight_type = psfight->fight_type;
    psfight->fight_record.fight_randomseed = psfight->fight_randomseed;
    psfight->fight_record.order_list = order_list;
    psfight->fight_record.fight_info_list = psfight->fight_info_list;
}

void CreateFightOdd( COddData::SData *podd, SFightOdd &fight_odd )
{
    fight_odd.id = podd->id;
    fight_odd.level = podd->level;
    fight_odd.status_id = podd->status.cate;
    fight_odd.status_value = podd->status.objid;
    fight_odd.start_round = 0;
    fight_odd.now_count = 1;
}

}// namespace fight

SO_LOAD( res_fightimp_register )
{
    fight::InitInterface();
}

