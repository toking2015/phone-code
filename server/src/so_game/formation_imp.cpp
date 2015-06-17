#include "formation_imp.h"
#include "local.h"
#include "proto/constant.h"
#include "proto/fight.h"
#include "misc.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "formation_event.h"
#include "resource/r_levelext.h"
#include "resource/r_formationindexext.h"

namespace formation
{

struct Formation_EqualGuid
{
    uint32 guid;
    uint32 attr;
    Formation_EqualGuid(uint32 _g, uint32 _a) : guid(_g), attr(_a){}
    bool operator () (const SUserFormation& formation)
    {
        return formation.guid == guid && formation.attr == attr;
    }
};

struct Formation_EqualIndex
{
    uint32 index;
    Formation_EqualIndex(uint32 _i) : index(_i){}
    bool operator() (const SUserFormation& formation)
    {
        return index == formation.formation_index;
    }
};

bool CheckExist(SUser *user, std::vector<SUserFormation> &formation)
{
    //检查是否存在
    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        switch( iter->attr )
        {
        case kAttrSoldier:
            {
                if ( !soldier::CheckSoldierGuid(user, iter->guid) )
                    return false;
            }
            break;
        case kAttrTotem:
            {
                if ( !totem::CheckTotem(user,iter->guid) )
                    return false;
            }
            break;
        default:
            return false;
        }
    }
    return true;
}

bool CheckIndex(SUser *user, std::vector<SUserFormation> &formation)
{
   //检查是否存在
    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        CFormationIndexData::SData *pdata = theFormationIndexExt.Find(iter->formation_index);
        if( NULL == pdata )
            return false;
        if( pdata->level > user->data.simple.team_level )
            return false;
    }
    return true;
}

bool CheckAttr(std::vector<SUserFormation> &formation)
{
    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        if( iter->attr == kAttrTotem && 0 != iter->formation_index%3 )
            return false;

        if( iter->attr != kAttrTotem && 0 == iter->formation_index%3 )
            return false;
    }

    return true;
}

bool CheckCount(SUser *user, std::vector<SUserFormation> &formation)
{
    CLevelData::SData *plevel_data = theLevelExt.Find(user->data.simple.team_level);
    if(NULL == plevel_data)
        return false;
    uint32 formation_count = 0;
    uint32 formation_totem_count = 0;

    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        if( iter->attr == kAttrTotem )
        {
            formation_totem_count++;
            continue;
        }

        if( iter->attr == kAttrSoldier )
        {
            formation_count++;
            continue;
        }
    }

    if( plevel_data->formation_count < formation_count )
        return false;
    if( plevel_data->formation_totem_count < formation_totem_count )
        return false;
    return true;
}

bool CheckSameGuid(SUser *user, std::vector<SUserFormation> &formation)
{
    std::map<uint32,std::map<uint32, uint32> > same_map;
    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        if ( 0 != same_map[iter->attr][iter->guid] )
            return false;
        same_map[iter->attr][iter->guid] = iter->guid;
    }
    return true;
}

bool CheckSameIndex(SUser *user, std::vector<SUserFormation> &formation)
{
    std::map<uint32, uint32> same_index;
    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        if ( 0 != same_index[iter->formation_index] )
            return false;
        same_index[iter->formation_index] = iter->guid;
    }
    return true;
}

void SetFormationType(uint32 type, std::vector<SUserFormation> &formation)
{
    for( std::vector<SUserFormation>::iterator iter = formation.begin();
        iter != formation.end();
        ++iter )
    {
        if ( iter->formation_type != type )
            iter->formation_type = type;
    }
}

bool IsValidType(SUser *user, std::vector<SUserFormation> &formation, uint32 type )
{
    switch ( type )
    {
    case kFormationTypeCommon:
    case kFormationTypeSingleArenaAct:
    case kFormationTypeSingleArenaDef:
    case kFormationTypeTrialSurvival:
    case kFormationTypeTrialStrength:
    case kFormationTypeTrialAgile:
    case kFormationTypeIntelligence:
    case kFormationTypeTomb:
        {
            //检查是否存在
            if(!CheckExist(user,formation))
                return false;
            //检查空格等级
            if(!CheckIndex(user,formation))
                return false;
            //检查前面一排是totem后面两排是武将
            if(!CheckAttr(formation))
                return false;
            //检查数量
            if(!CheckCount(user,formation))
                return false;
            //检查是否存在相同GUID
            if(!CheckSameGuid(user,formation))
                return false;
            //检查是否存在同一个位置
            if(!CheckSameIndex(user,formation))
                return false;
            //设置类型的阵型
            SetFormationType(type,formation);
       }
        break;
    default:
        return false;
    }
    return true;
}

uint32 GetYesCount( SUser *puser, uint32 type )
{
    std::vector<SUserFormation>& formation_list = puser->data.formation_map[type];
    return formation_list.size();
}

void GetFormation( SUser *puser, uint32 type, std::vector<SUserFormation>& formation_list )
{
    formation_list = puser->data.formation_map[type];
}

void Init( SUser* puser, uint32 type )
{
}

void ReplyList( SUser* puser, uint32 type )
{
    PRFormationList rep;
    bccopy(rep, puser->ext);
    rep.formation_type = type;
    rep.formation_list = puser->data.formation_map[type];
    local::write( local::access, rep );
}

bool Set( SUser *user, std::vector<SUserFormation> &formation, uint32 formation_type )
{
    if ( !IsValidType(user, formation, formation_type ) )
    {
        ReplyList(user, formation_type);
        return false;
    }

    std::vector<SUserFormation>& formation_list = user->data.formation_map[formation_type];

    formation_list = formation;

    ReplyList( user, formation_type );
    event::dispatch(SEventFormationSet(user, kPathFormationSet, formation_type));
    return true;
}

void DelTotem( SUser *puser, uint32 totem_guid )
{
    for( std::map<uint32, std::vector<SUserFormation> >::iterator iter = puser->data.formation_map.begin();
        iter != puser->data.formation_map.end();
        ++iter )
    {
        std::vector<SUserFormation> &list = iter->second;
        for( std::vector<SUserFormation>::iterator jter = list.begin();
            jter != list.end();
            )
        {
            if ( jter->attr == kAttrTotem && jter->guid == totem_guid )
            {
                uint32 formation_type = jter->formation_type;
                jter = list.erase(jter);
                ReplyList(puser, formation_type);
            }
            else
                ++jter;
        }
    }
}

}// namespace formation

