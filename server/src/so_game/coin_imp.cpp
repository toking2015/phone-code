#include "coin_imp.h"
#include "coin_event.h"
#include "item_imp.h"
#include "strength_imp.h"
#include "building_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "temple_imp.h"
#include "equip_imp.h"
#include "proto/constant.h"
#include "proto/notify.h"
#include "local.h"
#include "log.h"
#include "pro.h"

//uint32 最大值为 20e, 因为 lua 只能使用 int32, 将来再考来扩展
#define BASE_MAX_VALUE      2000000000

namespace coin
{

bool valid( S3UInt32& coin )
{
    return ( coin.cate != kCoinNone && coin.val != 0 );
}

bool valid( std::vector< S3UInt32 >& coins )
{
    for ( std::vector< S3UInt32 >::iterator iter = coins.begin();
        iter != coins.end();
        ++iter )
    {
        if ( valid( *iter ) )
            return true;
    }

    return false;
}

S3UInt32 create( uint32 cate, uint32 objid, uint32 val )
{
    S3UInt32 coin;
    coin.cate = cate;
    coin.objid = objid;
    coin.val = val;

    return coin;
}

std::vector< S3UInt32 > merge_coins( std::vector< S3UInt32 >& coins )
{
    std::vector< S3UInt32 > list;

    for ( std::vector< S3UInt32 >::iterator i = coins.begin();
        i != coins.end();
        ++i )
    {
        if ( !valid( *i ) )
            continue;

        std::vector< S3UInt32 >::iterator j = list.begin();
        for ( ; j != list.end(); ++j )
        {
            if ( j->cate == i->cate && j->objid == i->objid )
            {
                j->val += i->val;
                break;
            }
        }
        if ( j == list.end() )
            list.push_back( *i );
    }

    return list;
}

uint32* get_coin_raw_pointer( SUser* user, uint32 type )
{
    switch ( type )
    {
    case kCoinMoney:
        return &( user->data.coin.money );
    case kCoinGold:
        return &( user->data.coin.gold );
    case kCoinTicket:
        return &( user->data.coin.ticket );
    case kCoinWater:
        return &( user->data.coin.water );
    case kCoinStar:
        return &( user->data.coin.star );
    case kCoinActiveScore:
        return &( user->data.coin.active_score );
    case kCoinMedal:
        return &( user->data.coin.medal );
    case kCoinStrength:
        return &( user->data.simple.strength );
    case kCoinTeamXp:
        return &( user->data.simple.team_xp );
    case kCoinTeamLevel:
        return &( user->data.simple.team_level );
    case kCoinVipXp:
        return &( user->data.simple.vip_xp );
    case kCoinVipLevel:
        return &( user->data.simple.vip_level );
    case kCoinTomb:
        return &( user->data.coin.tomb );
    case kCoinGuildContribute:
        return &( user->data.coin.guild_contribute );
    case kCoinDayTaskVal:
        return &( user->data.coin.day_task_val );
    }

    return NULL;
}

//获取当前货币量
uint32 count( SUser* user, S3UInt32& coin )
{
    uint32* pointer = get_coin_raw_pointer( user, coin.cate );
    if ( pointer != NULL )
        return *pointer;

    switch ( coin.cate )
    {
    case kCoinItem:
    case kCoinEquipWhite:
    case kCoinEquipGreen:
    case kCoinEquipBlue:
    case kCoinEquipPurple:
    case kCoinEquipOrange:
        return item::GetItemCount( user, coin.objid );
    case kCoinBuilding:
        return building::GetCount( user, coin.objid );
    case kCoinSoldier:
        return soldier::CheckSoldier( user, coin.objid ) ? 1 : 0;
    case kCoinTotem:
        return totem::CheckTotemById( user, coin.objid ) ? 1 : 0;
    case kCoinGlyph:
        return temple::GetGlyphCount(user, coin.objid);
    case kCoinTempleScore:
        return temple::GetScore(user);
    default:
        assert( false );
    }

    return 0;
}

//给予货币
void give( SUser* user, S3UInt32& coin, uint32 path, uint32 flag/* = 0 */ )
{
    if ( coin.val <= 0 )
        return;

    //货币可增加空间
    uint32 space_value = space( user, coin );

    //货币溢出
    if ( state_not( flag, kCoinFlagOverflow ) && coin.val > space_value )
        coin.val = space_value;

    //优先通知客户端货币修改
    if ( state_not( flag, kCoinFlagQuiet ) )
    {
        PRNotifyCoin msg;
        bccopy( msg, user->ext );

        msg.set_type = kObjectAdd;
        msg.path = path;
        msg.coins.push_back( coin );

        local::write( local::access, msg );
    }

    //处理货币逻辑, 逻辑处理在客户端通知之后, 因为 event::dispatch 可能会对货币数据进行二次修改
    do
    {
        uint32* pointer = get_coin_raw_pointer( user, coin.cate );
        if ( pointer != NULL )
        {
            uint32 old_value = *pointer;

            *pointer += coin.val;

            event::dispatch( SEventCoin( user, path, coin.cate, coin.objid, coin.val, kObjectAdd, old_value ) );
            break;
        }

        switch ( coin.cate )
        {
        case kCoinItem:
            item::AddItem( user, coin.objid, coin.val, path, flag );
            break;
        case kCoinBuilding:
            building::AddValue( user, coin.objid, coin.val, path );
            break;
        case kCoinSoldier:
            soldier::Add( user, coin.objid, path, coin.val );
            break;
        case kCoinTotem:
            totem::Add(user, coin.objid, path);
            break;
        case kCoinGlyph:
            temple::AddGlyph(user, coin.objid, path);
            break;
        case kCoinEquipWhite:
        case kCoinEquipGreen:
        case kCoinEquipBlue:
        case kCoinEquipPurple:
        case kCoinEquipOrange:
            equip::Add(user, coin.cate, coin.objid, coin.val, path);
            break;
        default:
            assert( false );
        }

    }while(0);
}
void give( SUser* user, std::vector< S3UInt32 > coins, uint32 path, uint32 flag/* = 0 */ )
{
    if ( coins.empty() )
        return;

    coins = merge_coins( coins );

    //优先通知客户端
    if ( state_not( flag, kCoinFlagQuiet ) )
    {
        PRNotifyCoin msg;
        bccopy( msg, user->ext );

        msg.coins = coins;

        msg.set_type = kObjectAdd;
        msg.path = path;

        local::write( local::access, msg );
    }

    //给予货币
    for ( std::vector< S3UInt32 >::iterator i = coins.begin();
        i != coins.end();
        ++i )
    {
        //这里使用 kCoinFlagQuiet 避免 give 下层函数重复通知用户
        give( user, *i, path, state_add( flag, kCoinFlagQuiet ) );
    }
}

//检查是否有足够空间给予货币
uint32 check_give( SUser* user, S3UInt32& coin )
{
    uint32 value = space( user, coin );

    if ( coin.val <= value )
        return 0;

    return coin.cate;
}
uint32 check_give( SUser* user, std::vector< S3UInt32 >& coins )
{
    std::vector< S3UInt32 > list = merge_coins( coins );

    int32 item_space_count = -1;
    for ( std::vector< S3UInt32 >::iterator i = list.begin();
        i != list.end();
        ++i )
    {
        uint32 ret = 0;

        switch ( i->cate )
        {
        case kCoinItem:
            {
                //初始化背包空格子
                if ( item_space_count < 0 )
                    item_space_count = (int32)item::GetItemSpace( user, kBagFuncCommon );

                //获取物品叠加量
                uint32 stackable = 1;
                {
                    CItemData::SData* pitem = theItemExt.Find( i->objid );
                    if ( pitem != NULL && pitem->stackable > 1 )
                        stackable = pitem->stackable;

                }

                //获取已存在物品可叠加数量
                uint32 item_stackable_count = 0;

                if ( stackable > 1 )
                    item_stackable_count = item::GetItemStackableCount( user, kBagFuncCommon, i->objid );

                //可叠加量足够直接返回
                if ( item_stackable_count >= i->val )
                    break;

                //扣取可叠加量
                i->val -= item_stackable_count;

                //计算剩余量需占用的空格子数
                uint32 space_value = i->val / stackable;
                if ( i->val % stackable )
                    space_value++;

                if ( item_space_count < (int32)space_value )
                    return i->cate;

                //扣取空格子
                item_space_count -= space_value;
            }
            break;
        }

        ret = check_give( user, *i );
        if ( ret != 0 )
            return ret;
    }

    return 0;
}

//扣取货币( 有多少扣多少, 不作货币不够的判断 )
void take( SUser* user, S3UInt32& coin, uint32 path, uint32 flag/* = 0 */ )
{
    uint32 value = count( user, coin );
    if ( coin.val > value )
        coin.val = value - coin.val;

    if ( coin.val <= 0 )
        return;

    //优先通知客户端货币修改
    if ( state_not( flag, kCoinFlagQuiet ) )
    {
        PRNotifyCoin msg;
        bccopy( msg, user->ext );

        msg.set_type = kObjectDel;
        msg.path = path;
        msg.coins.push_back( coin );

        local::write( local::access, msg );
    }

    //处理货币逻辑, 逻辑处理在客户端通知之后, 因为 event::dispatch 可能会对货币数据进行二次修改
    do
    {
        uint32* pointer = get_coin_raw_pointer( user, coin.cate );
        if ( pointer != NULL )
        {
            uint32 old_value = *pointer;

            *pointer -= coin.val;

            event::dispatch( SEventCoin( user, path, coin.cate, coin.objid, coin.val, kObjectDel, old_value ) );
            break;
        }

        switch ( coin.cate )
        {
        case kCoinItem:
            item::DelItemById( user, coin.objid, coin.val, path );
            break;
        case kCoinBuilding:
            building::TakeValue( user, coin.objid, coin.val, path );
            break;
        case kCoinSoldier:
            soldier::TakeId( user, coin.objid, path, coin.val );
            break;
        case kCoinTotem:
            totem::Del( user, coin.objid, path );
            break;
        default:
            assert( false );
        }

    }while(0);
}
void take( SUser* user, std::vector< S3UInt32 > coins, uint32 path, uint32 flag/* = 0 */ )
{
    if ( coins.empty() )
        return;

    coins = merge_coins( coins );

    //优先通知客户端
    if ( state_not( flag, kCoinFlagQuiet ) )
    {
        PRNotifyCoin msg;
        bccopy( msg, user->ext );

        msg.coins = coins;

        msg.set_type = kObjectDel;
        msg.path = path;

        local::write( local::access, msg );
    }

    //扣除货币
    for ( std::vector< S3UInt32 >::iterator i = coins.begin();
        i != coins.end();
        ++i )
    {
        take( user, *i, path, state_add( flag, kCoinFlagQuiet ) );
    }
}

//检查货币是否足够扣取货币
uint32 check_take( SUser* user, S3UInt32& coin )
{
    uint32 value = count( user, coin );

    if ( value >= coin.val )
        return 0;

    return coin.cate;
}
uint32 check_take( SUser* user, std::vector< S3UInt32 >& coins )
{
    std::vector< S3UInt32 > list = merge_coins( coins );

    bool hasVal = false;
    for ( std::vector< S3UInt32 >::iterator i = list.begin();
        i != list.end();
        ++i )
    {
        if ( i->val > 0 )
            hasVal = true;

        uint32 ret = check_take( user, *i );
        if ( ret != 0 )
            return ret;
    }

    //coins 至少一个 val != 0
    if ( !hasVal )
        return 0x7FFFFFFF;

    return 0;
}

//获取货币剩余空间
uint32 space( SUser* user, S3UInt32& coin )
{
    switch ( coin.cate )
    {
    case kCoinItem:
        return item::GetItemSpace( user, kBagFuncCommon, coin.objid );
    case kCoinBuilding:
        return building::GetSpace( user, coin.objid );
    case kCoinSoldier:
    case kCoinTotem:
    case kCoinGlyph:
        return BASE_MAX_VALUE;
    case kCoinStrength:
        return strength::GetSpace( user );
    case kCoinEquipWhite:
    case kCoinEquipGreen:
    case kCoinEquipBlue:
    case kCoinEquipPurple:
    case kCoinEquipOrange:
        return item::GetItemSpace( user, kBagFuncSoldierEquip, coin.objid );
    }

    uint32* pointer = get_coin_raw_pointer( user, coin.cate );
    if ( pointer != NULL )
    {
        uint32 max_value = BASE_MAX_VALUE;

        if ( *pointer > max_value )
            return 0;

        return max_value - *pointer;
    }

    return 0;
}
uint32 space( SUser* user, uint32 cate )
{
    S3UInt32 coin = create( cate, 0, 0 );

    return space( user, coin );
}

void reply_lack( SUser* user, uint32 type )
{
    HandleErrCode( user, kErrCoinLack, type );
}

} // namespace coin

#undef BASE_MAX_VALUE

