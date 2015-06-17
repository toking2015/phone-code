#include "fightextable_imp.h"
#include "local.h"
#include "proto/fightextable.h"
#include "proto/constant.h"
#include "proto/formation.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "misc.h"
#include "luamgr.h"

namespace fightextable
{

struct FightExtAble_EqualGuid
{
    uint32 guid;
    uint32 attr;
    FightExtAble_EqualGuid(uint32 _g, uint32 _a):guid(_g), attr(_a){}
    bool operator ()( SFightExtAbleInfo &fightextable )
    {
        return fightextable.guid == guid && fightextable.attr == attr;
    }
};

bool IsValidAttr( uint32 attr )
{
    if ( kAttrPlayer == attr
        || kAttrSoldier == attr
        || kAttrSoldierYesterday == attr )
        return true;
    return false;
}

bool GetAbleInfo( SUser *user, uint32 guid, uint32 attr, SFightExtAbleInfo &fightextable )
{
    if ( !IsValidAttr( attr ) )
        return false;
    std::vector<SFightExtAbleInfo> &fightextable_list = user->data.fightextable_map[attr];
    std::vector<SFightExtAbleInfo>::iterator iter = std::find_if( fightextable_list.begin(), fightextable_list.end(), FightExtAble_EqualGuid(guid, attr) );
    if ( iter == fightextable_list.end() )
        return false;
    fightextable = *iter;
    return true;
}

bool GetFightExtAble( SUser *user, uint32 guid, uint32 attr, SFightExtAble &fightextable )
{
    if ( !IsValidAttr( attr ) )
        return false;
    std::vector<SFightExtAbleInfo> &fightextable_list = user->data.fightextable_map[attr];
    std::vector<SFightExtAbleInfo>::iterator iter = std::find_if( fightextable_list.begin(), fightextable_list.end(), FightExtAble_EqualGuid(guid, attr) );
    if ( iter == fightextable_list.end() )
        return false;
    fightextable = iter->able;
    return true;
}

uint32 GetFightExtAbleHP( SUser *user, uint32 guid, uint32 attr )
{
    if ( !IsValidAttr( attr ) )
        return 0;
    std::vector<SFightExtAbleInfo> &fightextable_list = user->data.fightextable_map[attr];
    std::vector<SFightExtAbleInfo>::iterator iter = std::find_if( fightextable_list.begin(), fightextable_list.end(), FightExtAble_EqualGuid(guid, attr) );
    if ( iter == fightextable_list.end() )
        return 0;
    return iter->able.hp;
}

void UpdateSoldierAble( SUser *user, S2UInt32 soldier, uint32 path )
{
    PRFightExtAbleSet rep;

    std::vector<SFightExtAbleInfo> &fightextable_list = user->data.fightextable_map[kAttrSoldier];

    std::vector<SFightExtAbleInfo>::iterator iter = std::find_if( fightextable_list.begin(), fightextable_list.end(), FightExtAble_EqualGuid(soldier.second, kAttrSoldier) );
    if ( iter == fightextable_list.end() )
    {
        SFightExtAbleInfo info;
        info.guid = soldier.second;
        info.attr = kAttrSoldier;
        if ( soldier::GetSoldierExt(user, soldier, info.able) )
        {
            fightextable_list.push_back( info );
            rep.set_type = kObjectAdd;
            rep.fightextable = info;
        }
    }
    else
    {
        if ( !soldier::GetSoldierExt(user, soldier, iter->able) )
        {
            rep.set_type = kObjectDel;
            fightextable_list.erase(iter);
        }
        else
        {
            rep.set_type = kObjectUpdate;
            rep.fightextable = *iter;
        }
    }
    bccopy( rep, user->ext );
    local::write( local::access, rep );

    UpdateFightValue(user);
}

void UpdateAllAble( SUser *user, uint32 path )
{
    //武将
    std::vector<SFightExtAbleInfo> &soldier_fightextable_list = user->data.fightextable_map[kAttrSoldier];
    soldier_fightextable_list.clear();
    std::map< uint32, std::map< uint32, SUserSoldier > > &soldier_map = user->data.soldier_map;
    for( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        if( iter->first != kSoldierTypeCommon )
            continue;
        std::map< uint32, SUserSoldier > &soldier_map = iter->second;
        for( std::map< uint32, SUserSoldier >::iterator jter = soldier_map.begin();
            jter != soldier_map.end();
            ++jter )
        {
            S2UInt32 soldier;
            soldier.first = jter->second.soldier_type;
            soldier.second = jter->second.guid;
            SFightExtAbleInfo info;
            info.guid = soldier.second;
            info.attr = kAttrSoldier;
            if ( soldier::GetSoldierExt(user, soldier, info.able) )
                soldier_fightextable_list.push_back( info );
        }
    }
    
    ReplyList( user, kAttrSoldier );

    UpdateFightValue(user);
}

void ReplyList( SUser *puser, uint32 attr )
{
    if ( !IsValidAttr(attr) )
        return;
    PRFightExtAbleList rep;
    rep.attr = attr;
    bccopy( rep, puser->ext );
    rep.fightextable_list = puser->data.fightextable_map[attr];
    local::write(local::access, rep);
}

void Init( SUser *puser )
{
}

void UpdateFightValue( SUser *user )
{
    uint32 fight_value = 0;

    SFightExtAble able;
    std::vector<SUserFormation>& formation_list = user->data.formation_map[kFormationTypeCommon];
    for( std::vector<SUserFormation>::iterator iter = formation_list.begin();
        iter != formation_list.end();
        ++iter )
    {
        if ( iter->attr == kAttrSoldier )
        {
            if ( GetFightExtAble( user, iter->guid, iter->attr, able ) )
            {
                fight_value += uint32( std::max( able.physical_ack, able.magic_ack )* 5.0 + ( able.physical_def + able.magic_def ) * 2.5 + able.hp * 0.4 );
            }
        }
    }

    user->data.simple.fight_value = fight_value;
    user->data.info.history_fight_value = user->data.info.history_fight_value > fight_value ? user->data.info.history_fight_value : fight_value;
}

uint32 GetFightValue( SUser *user, uint32 type )
{
    uint32 fight_value = 0;

    SFightExtAble able;

    if( user->data.formation_map.find( type ) == user->data.formation_map.end() )
        return fight_value;

    std::vector<SUserFormation>& formation_list = user->data.formation_map[type];
    for( std::vector<SUserFormation>::iterator iter = formation_list.begin();
        iter != formation_list.end();
        ++iter )
    {
        if ( iter->attr == kAttrSoldier )
        {
            if ( GetFightExtAble( user, iter->guid, iter->attr, able ) )
            {
                fight_value += uint32( std::max( able.physical_ack, able.magic_ack )* 5.0 + ( able.physical_def + able.magic_def ) * 2.5 + able.hp * 0.4 );
            }
        }
    }

    return fight_value;
}

}// namespace fightextable
