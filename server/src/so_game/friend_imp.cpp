#include "proto/friend.h"
#include "proto/constant.h"
#include "proto/item.h"
#include "friend_imp.h"
#include "user_dc.h"
#include "guild_dc.h"
#include "friend_dc.h"
#include "local.h"
#include "misc.h"
#include "pro.h"
#include "util.h"
#include "server.h"
#include "coin_imp.h"
#include "var_imp.h"
#include "item_imp.h"
#include "mail_imp.h"
#include "resource/r_globalext.h"
#include "resource/r_itemext.h"
#include "friend_event.h"

namespace frd
{

    void        ReplyFriendList( SUser* puser )
    {
        PRFriendList    rep;

        SUser* pfriend = NULL;

        for( std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.begin();
            iter != puser->data.friend_map.end();
            ++iter )
        {
            //更新数据
            pfriend = theUserDC.find( iter->second.friend_id );
            if( pfriend )
            {
                SetData( pfriend, iter->second, iter->second.friend_group );
            }

            rep.friend_list.push_back( iter->second );
        }

        bccopy( rep, puser->ext );
        local::write( local::access, rep );
    }

    void        ReplyFriendLimitList( SUser* puser )
    {
        PRFriendLimitList    rep;

        for( std::map< uint32, SFriendLimit >::iterator iter = puser->data.friend_limit_map.begin();
            iter != puser->data.friend_limit_map.end();
            ++iter )
        {
            rep.limit_list.push_back( iter->second );
        }

        bccopy( rep, puser->ext );
        local::write( local::access, rep );
    }


    void        ReplyFriendUpdate( SUser* puser, uint8 set_type, SUserFriend& data )
    {
        PRFriendUpdate rep;
        rep.info        = data;
        rep.set_type    = set_type;

        bccopy( rep, puser->ext );
        local::write( local::access, rep );

    }

    void        ReplyFriendLimitUpdate( SUser* puser, uint8 set_type, SFriendLimit& data )
    {
        PRFriendLimitUpdate rep;
        rep.info        = data;
        rep.set_type    = set_type;

        bccopy( rep, puser->ext );
        local::write( local::access, rep );

    }

    void        MakeFriend( SUser* puser, uint32 friend_id )
    {

        uint32 limit_level = theGlobalExt.get<uint32>("friend_system_level_limit");

        if( puser->data.simple.team_level < limit_level )
        {
            HandleErrCode( puser, kErrFriendSelfLevelLimit, 0 );
            return;
        }

        SUser* target = theUserDC.find( friend_id);
        if( target == NULL )
        {
            HandleErrCode( puser, kErrFriendOffline, 0 );
            return;
        }

        if( target->data.simple.team_level < limit_level )
        {
            HandleErrCode( puser, kErrFriendFrinedLevelLimit, 0 );
            return;
        }

        std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.find( friend_id );

        if( iter != puser->data.friend_map.end() )
        {
            if( iter->second.friend_group == kFriendGroupFriend )
            {
                HandleErrCode( puser, kErrFriendExist, 0 );
                return;
            }
        }

        //对方拉黑自己，直接无视申请协议
        iter = target->data.friend_map.find( puser->guid );
        if( iter != target->data.friend_map.end() )
        {
            if( iter->second.friend_group == kFriendGroupBlack )
                return;
        }

        SUserFriend d_friend;
        SetData( puser, d_friend, kFriendGroupFriend );

        PRFriendRequest rep;
        rep.target_id = puser->guid;
        rep.info      = d_friend;
        bccopy( rep, target->ext );
        local::write( local::access, rep );
    }

    void        MakeFriendByName( SUser* puser, std::string& target_name )
    {
        uint32 target_id = theUserDC.find_id( target_name );

        MakeFriend( puser, target_id );
    }

    void        AddFriend( SUser* puser, uint32 friend_id )
    {
        uint32 limit_level = theGlobalExt.get<uint32>("friend_system_level_limit");
        if( puser->data.simple.team_level < limit_level )
        {
            HandleErrCode( puser, kErrFriendSelfLevelLimit, 0 );
            return;
        }

        if( puser->guid == friend_id )
        {
            HandleErrCode( puser, kErrFriendSelf, 0 );
            return;
        }

        SUser* target = theUserDC.find( friend_id);
        if( target == NULL )
        {
            HandleErrCode( puser, kErrFriendOffline, 0 );
            return;
        }


        if( target && target->data.simple.team_level < limit_level )
        {
            HandleErrCode( puser, kErrFriendFrinedLevelLimit, 0 );
            return;
        }

        uint32  u_settype = kObjectAdd;
        uint32  t_settype = kObjectAdd;

        //如果对方是在自己的黑名单里，那么就是伪造协议
        std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.find( friend_id );
        if( iter != puser->data.friend_map.end() )
        {
            if( iter->second.friend_group == kFriendGroupBlack )
                return;

            //更新好友数据　如：从陌生人变为好友
            u_settype = kObjectUpdate;
        }

        iter = target->data.friend_map.find( puser->guid );
        if( iter != target->data.friend_map.end() )
        {
            //更新好友数据　如：从陌生人变为好友
            t_settype = kObjectUpdate;
        }

        SUserFriend d_friend;

        SetData( target, d_friend, kFriendGroupFriend );
        puser->data.friend_map[ friend_id ] = d_friend;
        ReplyFriendUpdate( puser, u_settype, d_friend );

        SetData( puser, d_friend, kFriendGroupFriend );
        target->data.friend_map[ puser->guid ] = d_friend;
        ReplyFriendUpdate( target, t_settype, d_friend );

        if( target )
        {
            PRFriendMake rep;
            rep.target_id = puser->guid;
            rep.info      = d_friend;
            bccopy( rep, target->ext );
            local::write( local::access, rep );
        }
    }

    void        AddStranger( SUser* puser, uint32 target_id )
    {
        uint32 limit_level = theGlobalExt.get<uint32>("friend_system_level_limit");
        if( puser->data.simple.team_level < limit_level )
        {
            HandleErrCode( puser, kErrFriendSelfLevelLimit, 0 );
            return;
        }

        SUser* target = theUserDC.find( target_id);
        if( target == NULL )
        {
            return;
        }

        SUserFriend d_friend;
        SetData( target, d_friend, kFriendGroupStranger );
        puser->data.friend_map[ target_id ] = d_friend;
        ReplyFriendUpdate( puser, kObjectAdd, d_friend );
    }

    void        AddBlack( SUser* puser, uint32 target_id )
    {
        uint32 limit_level = theGlobalExt.get<uint32>("friend_system_level_limit");
        if( puser->data.simple.team_level < limit_level )
        {
            HandleErrCode( puser, kErrFriendSelfLevelLimit, 0 );
            return;
        }

        SUser* target = theUserDC.find( target_id);
        if( target == NULL )
        {
            return;
        }

        std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.find( target_id );

        if( iter != puser->data.friend_map.end() )
        {
            if( iter->second.friend_group == kFriendGroupBlack )
                return;

            iter->second.friend_group = kFriendGroupBlack;
            ReplyFriendUpdate( puser, kObjectUpdate, iter->second );

            iter = target->data.friend_map.find( puser->guid );
            if( iter != target->data.friend_map.end() )
            {
                ReplyFriendUpdate( target, kObjectDel, iter->second );
                target->data.friend_map.erase( iter );
            }

            return;
        }

        SUserFriend d_friend;
        SetData( target, d_friend, kFriendGroupBlack );
        puser->data.friend_map[ target_id ] = d_friend;
        ReplyFriendUpdate( puser, kObjectAdd, d_friend );
    }


    void        Request( SUser* puser, SUser*  target )
    {
        std::map< uint32, SUserFriend >::iterator iter = target->data.friend_map.find( puser->guid );

        if( iter != target->data.friend_map.end() )
        {
            HandleErrCode( puser, kErrFriendExist, 0 );
            return;
        }

        SUserFriend d_friend;

        SetData( puser, d_friend, kFriendGroupFriend );

        PRFriendRequest rep;
        rep.target_id = puser->guid;
        rep.info      = d_friend;
        bccopy( rep, target->ext );
        local::write( local::access, rep );

    }

    void        SetData( SUser* puser, SUserFriend& data, uint8 group )
    {
        data.friend_id     = puser->guid;
        data.friend_favor  = 0;
        data.on_time       = 0;
        data.friend_group  = group;
        data.friend_avatar = puser->data.simple.avatar;
        data.friend_level  = puser->data.simple.team_level;
        data.friend_name   = puser->data.simple.name;
        if( puser->data.simple.guild_id > 0 )
        {
            SGuildSimple* pguilds = theGuildDC.find_simple( puser->data.simple.guild_id );
            if( pguilds )
                data.friend_gname = pguilds->name;
            else
                data.friend_gname = "";
        }
        else
            data.friend_gname = "";
    }

    void        SetDataByFriendData( SFriendData* pdata, SUserFriend& data, uint8 group )
    {
        data.friend_id     = pdata->target_id;
        data.friend_favor  = 0;
        data.on_time       = 0;
        data.friend_group  = group;
        data.friend_avatar = pdata->target_avatar;
        data.friend_level  = pdata->target_level;
        data.friend_name   = pdata->target_name;
        data.friend_gname  = "";
    }

    void        SendMsg( SUser* puser, SUser* target, std::string& msg )
    {
        std::map< uint32, SUserFriend >::iterator iter = target->data.friend_map.find( puser->guid );

        if( iter != target->data.friend_map.end() && iter->second.friend_group ==  kFriendGroupBlack )
            return;

        PRFriendMsg rep;
        rep.friend_id = puser->guid;
        rep.msg       = msg;
        bccopy( rep, target->ext );
        local::write( local::access, rep );
    }

    void        UpdateFriend( SUser* puser, uint32 target_id,  uint8 set_type, uint8 group )
    {
        std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.find( target_id );

        if( iter == puser->data.friend_map.end() )
        {
            HandleErrCode( puser, kErrFriendNoExist, 0 );
            return;
        }

        SUser* target = theUserDC.find( target_id );

        if( target == NULL )
            return;


        bool    data_update = false;

        SUserFriend data = iter->second;

        switch( set_type )
        {
        case kObjectDel:
            {
                puser->data.friend_map.erase( iter );

                data_update = true;
            }
            break;
        case kObjectUpdate:
            {
                if( group == kFriendGroupBlack )
                {
                    iter->second.friend_group = group;
                    data = iter->second;

                    data_update = true;
                }
            }
            break;
        }

        if( data_update )
        {
            ReplyFriendUpdate( puser, set_type, data );

            std::map< uint32, SUserFriend >::iterator t_iter = target->data.friend_map.find( puser->guid );
            if( t_iter != target->data.friend_map.end() )
            {
                ReplyFriendUpdate( target, kObjectDel, t_iter->second );
                target->data.friend_map.erase( t_iter );
            }
        }
    }

    void        Recommend( SUser* puser )
    {
        std::vector< uint32 > list;
        uint32 count = 5;
        uint32 target_id = 0;
        std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.end();

        for( uint32 i=0; i<count; ++i )
        {
            target_id = theFriendDC.Recommend();
            if( target_id == 0 )
                break;

            if( target_id == puser->guid )
                continue;

            iter = puser->data.friend_map.find( target_id );
            uint32 speed = 0;
            while( iter != puser->data.friend_map.end() )
            {
                if( speed == 100 )
                {
                    target_id = 0;
                    break;
                }

                ++speed;

                target_id = theFriendDC.Recommend();
                if( target_id == 0 )
                    break;

                iter = puser->data.friend_map.find( target_id );
            }

            if( target_id == 0 || target_id == puser->guid )
                break;

            uint32 is_add = true;
            for(std::vector<uint32>::iterator iter = list.begin();
                iter != list.end();
                ++iter )
            {
                if( *iter == target_id )
                {
                    is_add = false;
                    break;
                }
            }

            if( is_add )
                list.push_back( target_id );
        }

        if( !list.empty() )
        {
            SUserFriend         d_friend;
            SUser*              ptarget = NULL;
            SFriendData*        pdata = NULL;

            std::vector< SUserFriend > f_list;

            for( std::vector<uint32>::iterator iter = list.begin();
                iter != list.end();
                ++iter )
            {
                ptarget = theUserDC.find( *iter );
                if( ptarget )
                {
                    SetData( ptarget, d_friend, kFriendGroupFriend );
                    f_list.push_back( d_friend );
                }
                else
                {
                    pdata = theFriendDC.FindFriendData( *iter );
                    if( pdata )
                    {
                        SetDataByFriendData( pdata, d_friend, kFriendGroupFriend );
                        f_list.push_back( d_friend );
                    }
                }
            }
            PRFriendRecommend rep;
            rep.target_id_list = list;
            rep.friend_list    = f_list;
            bccopy( rep, puser->ext );
            local::write( local::access, rep );
        }

    }

    void        Give( SUser* puser, SUser* target, uint8 give_type, uint32 active_score, std::vector< S3UInt32 > &item_list )
    {
        uint32 friend_id = target->guid;

        std::map< uint32, SUserFriend >::iterator u_iter = puser->data.friend_map.find( friend_id );

        if( u_iter == puser->data.friend_map.end() )
        {
            HandleErrCode( puser, kErrFriendNoExist, 0 );
            return;
        }

        std::map< uint32, SUserFriend >::iterator t_iter = target->data.friend_map.find( puser->guid );

        if( t_iter == target->data.friend_map.end() )
        {
            HandleErrCode( puser, kErrFriendNoExistMine, 0 );
            return;
        }

        uint32 nowtime   = time(NULL);

        std::vector< S3UInt32 > add_list;
        S3UInt32 coin;
        switch( give_type )
        {
        case kFriendGiveOne:
            {
                coin.cate = kCoinActiveScore;
                coin.val  = active_score;

                uint32 get_max = var::get( target, "friend_get_activescore_max");
                uint32 get_limit = theGlobalExt.get<uint32>("friend_get_activescore_num_limit");

                if( get_max + 1  > get_limit )
                {
                    HandleErrCode( puser, kErrFriendActiveScoreMaxNumLimit, 0 );
                    return;
                }

                std::map< uint32, SFriendLimit >::iterator iter = puser->data.friend_limit_map.find( friend_id );

                if( iter != puser->data.friend_limit_map.end() )
                {
                    uint32 time_limit = theGlobalExt.get<uint32>("friend_give_activescore_time_limit");

                    if( nowtime < iter->second.time_limit + time_limit )
                    {
                        HandleErrCode( puser, kErrFriendActiveScoreLimit, 0 );
                        return;
                    }

                    //更新最后赠送时间
                    iter->second.time_limit = nowtime;

                    ReplyFriendLimitUpdate( puser, kObjectUpdate, iter->second );
                }
                else
                {
                    SFriendLimit data;
                    data.friend_id  = friend_id;
                    data.time_limit = nowtime;

                    puser->data.friend_limit_map[ friend_id ] = data;

                    ReplyFriendLimitUpdate( puser, kObjectAdd, data );
                }

                uint32 time_limit = server::local_6_time( 0, 1 );
                var::set( target, "friend_get_activescore_max", get_max + 1, time_limit );

                add_list.push_back( coin );
                std::ostringstream detail;
                detail << puser->data.simple.name.c_str() << " 向你发送了活跃度";
                mail::send( kMailFlagSystem, target->guid, "好友系统", "赠送活跃度", detail.str(), add_list, kPathFriendSend );

                PRFriendGive rep;
                rep.friend_id    = target->guid;
                rep.give_type    = give_type;
                rep.active_score = active_score;
                bccopy( rep, puser->ext );
                local::write( local::access, rep );

                event::dispatch( SEventFrdGiveActiveScore( puser, kPathFriendSend, target->guid,active_score ) );
            }
            break;
        case kFriendGiveTwo:
            {
                if ( item_list.empty() )
                {
                    HandleErrCode( puser, kErrFriendItemNoNum, 0 );
                    return;
                }
                uint32 send_limit = theGlobalExt.get<uint32>("friend_give_item_num_limit");
                uint32 send_count = 0;
                for( std::vector< S3UInt32 >::iterator iter = item_list.begin();
                    iter != item_list.end();
                    ++iter )
                {
                    send_count += iter->val;
                }

                if( send_count > send_limit )
                {
                    //HandleErrCode( puser, kErrFriendItemSendNumLimit, 0 );
                    return;
                }

                uint32 get_limit = theGlobalExt.get<uint32>("friend_get_item_num_limit");
                uint32 get_max   = var::get( target, "friend_get_item_max" );
                if( get_max + send_count > get_limit )
                {
                    PRFriendGiveLimit  rep;
                    rep.target_id   = target->guid;
                    rep.target_name = target->data.simple.name;
                    rep.max_num     = get_limit - get_max;

                    bccopy( rep, puser->ext );
                    local::write( local::access, rep );
                    //HandleErrCode( puser, kErrFriendItemMaxNumLimit, 0 );
                    return;
                }

                CItemData::SData* pitem = NULL;
                S2UInt32 bas_item;
                SUserItem dst_item;
                for( std::vector< S3UInt32 >::iterator iter = item_list.begin();
                    iter != item_list.end();
                    ++iter )
                {
                    bas_item.first  = iter->cate;
                    bas_item.second = iter->objid;

                    if( item::GetUserItem( puser, bas_item, dst_item ) == false )
                    {
                        HandleErrCode( puser, kErrItemGuidNotExist, 0 );
                        return;
                    }

                    if( dst_item.count < iter->val )
                    {
                        HandleErrCode( puser, kErrFriendItemNumNoEnough, 0 );
                        return;
                    }

                    //有时效的物品不能赠送
                    if( dst_item.due_time > 0 )
                        return;

                    //绑定的物品不能赠送
                    if( dst_item.flags == kCoinFlagBind )
                        return;

                    pitem = theItemExt.Find( dst_item.item_id );
                    if( pitem == NULL )
                    {
                        HandleErrCode( puser, kErrItemDataNotExist, 0 );
                        return;
                    }

                    if( pitem->can_exchange == 0 )
                    {
                        HandleErrCode( puser, kErrFriendItemEorror, 0 );
                        return;
                    }

                    //Item.xls中的bind不为"不绑定"不能赠送
                    if( pitem->bind != 0 )
                        return;

                    coin.cate       = kCoinItem;
                    coin.objid      = dst_item.item_id;
                    coin.val        = iter->val;
                    add_list.push_back( coin);
                }

                std::map< uint32, SFriendLimit >::iterator f_iter = puser->data.friend_limit_map.find( friend_id );

                if( f_iter != puser->data.friend_limit_map.end() )
                {

                    if( nowtime < f_iter->second.type_limit && f_iter->second.num_limit + send_count > send_limit )
                    {
                        //HandleErrCoder puser, kErrFriendItemSendNumLimit, 0 );
                        return;
                    }

                    if( nowtime > f_iter->second.type_limit )
                    {
                        //重置时间点与数量
                        f_iter->second.type_limit = server::local_6_time( 0, 1 );
                        f_iter->second.num_limit  = 0;
                    }

                    //更新赠送数量
                    f_iter->second.num_limit += send_count;
                    var::set( target, "friend_get_item_max", get_max + send_count, f_iter->second.type_limit );

                    ReplyFriendLimitUpdate( puser, kObjectUpdate, f_iter->second );
                }
                else
                {
                    SFriendLimit data;
                    data.friend_id  = friend_id;
                    data.type_limit = server::local_6_time( 0, 1 );
                    data.num_limit  = send_count;
                    var::set( target, "friend_get_item_max", send_count, data.type_limit );

                    puser->data.friend_limit_map[ friend_id ] = data;

                    ReplyFriendLimitUpdate( puser, kObjectAdd, data );
                }

                for( std::vector< S3UInt32 >::iterator iter = item_list.begin();
                    iter != item_list.end();
                    ++iter )
                {
                    bas_item.first  = iter->cate;
                    bas_item.second = iter->objid;
                    item::DelItemByGuid( puser, bas_item, iter->val, kPathFriendSend );
                }

                std::ostringstream detail;
                detail << puser->data.simple.name.c_str() << " 向你发送了物品";
                mail::send( kMailFlagSystem, target->guid, "好友系统", "赠送物品", detail.str(), add_list, kPathFriendSend, kCoinFlagBind );

                PRFriendGive rep;
                rep.friend_id    = target->guid;
                rep.give_type    = give_type;
                rep.active_score = active_score;
                bccopy( rep, puser->ext );
                local::write( local::access, rep );
            }
            break;
        }
    }


} // namespace frd

