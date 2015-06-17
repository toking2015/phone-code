#include "opentarget_imp.h"
#include "proto/constant.h"
#include "proto/copy.h"
#include "coin_imp.h"
#include "equip_imp.h"
#include "var_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "temple_imp.h"
#include "copy_imp.h"
#include "server.h"
#include "misc.h"
#include "local.h"

namespace opentarget
{

void    Take( SUser* puser, uint32 day, uint32 guid )
{
    std::string buff = strprintf( "opent_target_take_%d_%d", day, guid);
    uint32 value = var::get( puser, buff );
    if( value > 0 )
        return;

    if( CheckDay( day ) == false )
        return;

    COpenTargetData::SData *p_data = theOpenTargetExt.Find( day, guid );
    if( p_data == NULL )
        return;

    if( p_data->a_type == kOpenTargetActionTypeBuy )
        return;

    if( p_data->if_type == kOpenTargetIfTypeAll )
    {
        std::vector< COpenTargetData::SData* > list;
        theOpenTargetExt.FindList( day, list );
        for( std::vector< COpenTargetData::SData* >::iterator iter = list.begin();
            iter != list.end();
            ++iter )
        {

            if( (*iter)->a_type != kOpenTargetActionTypeBuy )
            {
                if( CheckFactor( puser, *iter ) == false )
                    return;
            }
        }

    }
    else
    {
        if( CheckFactor( puser, p_data ) == false )
            return;
    }


    coin::give( puser, p_data->reward, kPathOpenTargetTake );
    var::set( puser, buff, 1 );

    PROpenTargetTake rep;
    rep.day  = day;
    rep.guid = guid;
    bccopy( rep, puser->ext );
    local::write( local::access, rep );

}

void    Buy( SUser* puser, uint32 day, uint32 guid )
{
    if( CheckDay( day ) == false )
        return;

    COpenTargetData::SData *p_data = theOpenTargetExt.Find( day, guid );
    if( p_data == NULL )
        return;

    std::string buff = strprintf( "opent_target_buy_%d_%d", day, guid);
    uint32 value = var::get( puser, buff );
    if( value > 0 )
        return;

    if( p_data->a_type != kOpenTargetActionTypeBuy )
        return;

    if( coin::check_take( puser, p_data->coin_1 ) != 0 )
        return;

    coin::take( puser, p_data->coin_1,kPathOpenTargetBuy );
    coin::give( puser, p_data->item, kPathOpenTargetBuy );
    var::set( puser, buff, 1 );

    PROpenTargetBuy rep;
    rep.day  = day;
    rep.guid = guid;
    bccopy( rep, puser->ext );
    local::write( local::access, rep );

}

bool    CheckDay( uint32 day )
{
    uint32  open_time  = server::get<uint32>( "open_time" );
    open_time          = server::local_6_time( open_time );
    uint32  now_time   = server::local_6_time( 0 );

    uint32 sub_day     = 1;

    if( now_time > open_time )
        sub_day = ( now_time - open_time ) / 86400 + 1;

    if( sub_day > 10 )
        return false;

    return sub_day >= day;
}

bool    CheckFactor( SUser* puser, COpenTargetData::SData* p_data )
{
    if( p_data == NULL )
        return false;

    switch( p_data->if_type )
    {
    case kOpenTargetIfTypeLogin:
        {
            return true;
        }
        break;
    case kOpenTargetIfTypeAddPay:
        {
            if( puser->data.pay_info.pay_sum < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeMainCopy:
        {
            if( copy::get_boss_round( puser, p_data->if_value_2, kCopyMopupTypeNormal ) != 0 )
                return false;
        }
        break;
    case kOpenTargetIfTypePefectCopy:
        {
            if( copy::get_boss_round( puser, p_data->if_value_2, kCopyMopupTypeElite ) != 0 )
                return false;
        }
        break;
    case kOpenTargetIfTypeTeamLevel:
        {
            if( puser->data.simple.team_level < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeEquip:
        {
            if( equip::CountEquipSuit( puser, p_data->if_value_2 ) < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeSoldier:
        {
            if( soldier::GetSoldierCountByStar( puser, p_data->if_value_2 ) < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeSingleare:
        {
            if( puser->data.other.single_arena_rank > p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeTomb:
        {
            if( puser->data.tomb_info.history_win_count < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeTotem:
        {
            if( totem::GetTotemLevelCount( puser, p_data->if_value_2 ) < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeSoldierTeam:
        {
            if( puser->data.temple.group_list.size() < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeGlyph:
        {
            if( temple::GetEmbedGlyphCountByQuality( puser, p_data->if_value_2 ) < p_data->if_value_1 )
                return false;
        }
        break;
    case kOpenTargetIfTypeAll:
        {
            return true;
        }
        break;
    default:
        return false;
    }

    return true;

}

}

