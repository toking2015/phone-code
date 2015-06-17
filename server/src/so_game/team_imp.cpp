#include "team_imp.h"
#include "coin_imp.h"
#include "resource/r_levelext.h"
#include "resource/r_globalext.h"
#include "resource/r_avatarext.h"
#include "proto/coin.h"
#include "proto/team.h"
#include "team_event.h"
#include "user_dc.h"
#include "user_imp.h"
#include "pro.h"
#include "local.h"

namespace team
{

void level_up( SUser* user )
{
    uint32 team_level_max = theGlobalExt.get<uint32>( "team_level_max" );
    if ( team_level_max <= 0 )
        return;

    uint32 old_strength = user->data.simple.strength;

    uint16 old_level = user->data.simple.team_level;

    //扣取经验
    S3UInt32 coin_xp = coin::create( kCoinTeamXp, 0, 0 );

    //增加等级
    S3UInt32 coin_lv = coin::create( kCoinTeamLevel, 0, 1 );

    for ( int32 i = user->data.simple.team_level; i + 1 <= (int32)team_level_max; ++i )
    {
        CLevelData::SData* level = theLevelExt.Find( i );
        if ( level == NULL )
            break;

        //设置升级所需经验
        coin_xp.val = level->team_xp;

        //货币有效判断
        if ( coin::check_take( user, coin_xp ) != 0 )
            break;

        if ( coin::check_give( user, coin_lv ) != 0 )
            break;

        coin::take( user, coin_xp, kPathTeamLevelUp );
        coin::give( user, coin_lv, kPathTeamLevelUp );

        //升级事件
        event::dispatch( SEventTeamLevelUp( user, kPathTeamLevelUp, i ) );
    }

    if ( old_level != user->data.simple.team_level )
    {
        PRTeamLevelUp msg;
        bccopy( msg, user->ext );

        msg.old_strength    = old_strength;
        msg.old_level   = old_level;
        msg.new_level   = user->data.simple.team_level;

        local::write( local::access, msg );
    }
}

void change_name( SUser *user, std::string name )
{
    //判断名字是否正确
    if ( name.size() > 18 )
    {
        HandleErrCode(user, kErrTeamNameLong, 0 );
        return;
    }

    if( std::string::npos != name.find("　") || theGlobalExt.HasEspecial( name ) )
    {
        HandleErrCode(user, kErrTeamNameInvalid, 0 );
        return;
    }

    //判断名字是否重名
    if ( 0 != theUserDC.find_id( name ) )
    {
        HandleErrCode(user, kErrTeamNameHave, 0 );
        return;
    }

    //判断是否有足够的金币
    if ( user->data.team.change_name_count > 0 )
    {
        S3UInt32 cost;
        cost.cate = kCoinGold;
        cost.val = user->data.team.change_name_count * theGlobalExt.get<uint32>("change_name_cost_multiple");
        if( cost.val > theGlobalExt.get<uint32>("change_name_const_limit") )
            cost.val = theGlobalExt.get<uint32>("change_name_const_limit");

        uint32 result = coin::check_take( user, cost );
        if( 0 != result )
        {
            HandleErrCode(user, result, 0);
            return;
        }

        coin::take( user, cost, kPathChangeName );
    }

    user->data.simple.name = name;

    theUserDC.db().user_name_id[name] = user->guid;
    theUserDC.db().user_id_name[user->guid] = name;

    user->data.team.change_name_count++;

    PRTeamChangeName rep;
    rep.name = name;
    bccopy( rep, user->ext );
    local::write(local::access, rep);

    event::dispatch( SEventNameChange( user, kPathChangeName, name ) );
}

void change_avatar( SUser *puser, uint32 avatar )
{
    if ( puser->data.simple.avatar == avatar )
        return;

    CAvatarData::SData *pdata = theAvatarExt.Find( avatar );
    if ( NULL == pdata )
    {
        HandleErrCode( puser, kErrTeamAvatarNoExist, 0 );
        return;
    }

    puser->data.simple.avatar = avatar;

    user::ReplyUserSimple( puser, puser );

    event::dispatch( SEventAvatarChange( puser, kPathChangeAvatar, avatar ) );
}

} // namespace team

