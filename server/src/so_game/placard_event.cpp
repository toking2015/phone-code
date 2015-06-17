#include "event.h"
#include "util.h"
#include "proto/constant.h"
#include "proto/system.h"
#include "proto/broadcast.h"
#include "proto/coin.h"
#include "proto/copy.h"
#include "system_imp.h"
#include "soldier_event.h"
#include "coin_event.h"
#include "tomb_event.h"
#include "trial_event.h"
#include "copy_event.h"
#include "resource/r_soldierext.h"
#include "resource/r_soldierqualityext.h"

std::string format_user_name( SUser* user )
{
    return "[font=GG_NAME]" + user->data.simple.name;
}

std::string format_soldier_name( SUser* user, uint32 soldier_id )
{
    CSoldierData::SData* data = theSoldierExt.Find( soldier_id );
    if ( data == NULL )
        return "";

    return "[font=GG_WHITE]" + data->name;
}

std::string format_soldier_star_name( uint32 soldier_id )
{
    CSoldierData::SData* data = theSoldierExt.Find( soldier_id );
    if ( data == NULL )
        return "";

    return strprintf( "%d星", data->star );
}

std::string format_soldier_ext_name( uint32 quality )
{
    CSoldierQualityData::SData* data = theSoldierQualityExt.Find( quality );
    if ( data == NULL )
        return "";

    const char* color_names[] = { "", "白", "绿", "蓝", "紫", "橙" };
    const char* color_title[] = { "", "[font=GG_WHITE]", "[font=GG_GREEN]", "[font=GG_BLUE]", "[font=GG_PURPLE]", "[font=GG_YELLOW]" };
    if ( data->quality_effect.first < 0 || data->quality_effect.first >= sizeof( color_names ) / sizeof( const char* ) )
        return "";

    std::string text;
    if ( data->quality_effect.second != 0 )
    {
        text = strprintf( "%s%s色+%d",
            color_title[ data->quality_effect.first ], color_names[ data->quality_effect.first ], data->quality_effect.second );
    }
    else
    {
        text = strprintf( "%s%s色", color_title[ data->quality_effect.first ], color_names[ data->quality_effect.first ] );
    }

    return text;
}

EVENT_FUNC( sys, SEventSoldierStarUp )
{
    std::string text = strprintf( "%s[font=GG_WHITE]将%s[font=GG_WHITE]升到了%d[font=GG_WHITE]星!",
         format_user_name( ev.user ).c_str(),
         format_soldier_name( ev.user, ev.soldier_id ).c_str(),
         ev.old_star + 1 );

    sys::placard( 0, kPlacardFlagScene, text, kCastServer, 0, 0 );
}

EVENT_FUNC( sys, SEventSoldierQualityUp )
{
    CSoldierQualityData::SData* data = theSoldierQualityExt.Find( ev.old_quality + 1 );
    if ( data == NULL )
        return;

    if ( data->quality_effect.first >= 3 )
    {
        std::string text = strprintf( "%s[font=GG_WHITE]将%s[font=GG_WHITE]升到了%s",
            format_user_name( ev.user ).c_str(),
            format_soldier_name( ev.user, ev.soldier_id ).c_str(),
            format_soldier_ext_name( ev.old_quality + 1 ).c_str() );

        sys::placard( 0, kPlacardFlagScene, text, kCastServer, 0, 0 );
    }
}

EVENT_FUNC( sys, SEventCoin )
{
    switch ( ev.set_type )
    {
    case kObjectAdd:
        {
            switch ( ev.coin.cate )
            {
            case kCoinSoldier:
                {
                    CSoldierData::SData* data = theSoldierExt.Find( ev.coin.objid );
                    if ( data != NULL )
                    {
                        if ( data->star >= 4 )
                        {
                            std::string text = strprintf( "%s[font=GG_WHITE]获得了一个%s[font=GG_WHITE]英雄: %s",
                                format_user_name( ev.user ).c_str(),
                                format_soldier_star_name( ev.coin.objid ).c_str(),
                                format_soldier_name( ev.user, ev.coin.objid ).c_str() );

                            sys::placard( 0, kPlacardFlagScene, text, kCastServer, 0, 0 );
                        }
                    }
                }
                break;
            }
        }
        break;
    }
}

EVENT_FUNC( sys, SEventTombRewardGet )
{
    if ( ev.index == 20 || ev.index == 25 )
    {
        std::string text = strprintf( "%s[font=GG_WHITE]通关了大墓地第%u关!", format_user_name( ev.user ).c_str(), ev.index );

        sys::placard( 0, kPlacardFlagScene, text, kCastServer, 0, 0 );
    }
}

EVENT_FUNC( sys, SEventTrialRewardGet )
{
    if ( ev.index == 8 || ev.index == 10 )
    {
        std::string text = strprintf( "%s[font=GG_WHITE]在十字军试炼中拿到了%u个宝箱!", format_user_name( ev.user ).c_str(), ev.index );

        sys::placard( 0, kPlacardFlagScene, text, kCastServer, 0, 0 );
    }
}
/*
EVENT_FUNC( sys, SEventCopyAreaPresentTake )
{
    if ( ev.area_attr == kCopyAreaAttrFullStar && ev.mopup_type == kCopyMopupTypeElite )
    {
        std::string text = strprintf( "%s[font=GG_WHITE]通关了第%u章精英副本!太犀利了!", format_user_name( ev.user ).c_str(), ev.aid );

        sys::placard( 0, kPlacardFlagScene, text, kCastServer, 0, 0 );
    }
}
*/
