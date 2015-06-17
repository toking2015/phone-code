#include "soldier_imp.h"
#include "user_imp.h"
#include "totem_imp.h"
#include "coin_imp.h"
#include "coin_event.h"
#include "misc.h"
#include "local.h"
#include "netsingle.h"
#include "resource/r_soldierext.h"
#include "resource/r_soldierbaseext.h"
#include "resource/r_soldierqualityext.h"
#include "resource/r_soldierqualityxpext.h"
#include "resource/r_soldierqualityoccuext.h"
#include "resource/r_soldierlvext.h"
#include "resource/r_soldierstarext.h"
#include "resource/r_soldierrecruitext.h"
#include "resource/r_oddext.h"
#include "resource/r_levelext.h"
#include "proto/constant.h"
#include "event.h"
#include "pro.h"
#include "log.h"
#include "luamgr.h"
#include "fightextable_event.h"
#include "soldier_event.h"
#include "user_event.h"
#include "item_imp.h"
#include "equip_imp.h"
#include "temple_imp.h"
#include "resource/r_globalext.h"
#include "resource/r_effectext.h"

struct Soldier_EqualSoldierGuid
{
    uint32 guid;
    Soldier_EqualSoldierGuid(uint32 _guid) {guid = _guid;}
    bool operator () (const SUserSoldier& soldier)
    {
        return soldier.guid == guid;
    }
};

struct Soldier_EqualSoldierIndex
{
    uint16 index;
    Soldier_EqualSoldierIndex(uint16 _index) {index = _index;}
    bool operator () (const SUserSoldier& soldier)
    {
        return soldier.soldier_index == index;
    }
};

struct Soldier_EqualSoldierId
{
    uint32  id;
    Soldier_EqualSoldierId(uint32 _id) {id = _id;}
    bool operator () (const SUserSoldier& soldier)
    {
        return soldier.soldier_id == id;
    }
};

struct Soldier_EqualSkillID
{
    uint32 id;
    Soldier_EqualSkillID(uint32 _id) {id= _id;}
    bool operator () (const SSoldierSkill& skill)
    {
        return skill.id  == id;
    }
};

struct SEqualItemSoldierGuid
{
    uint32 guid;
    SEqualItemSoldierGuid(uint32 _guid) {guid = _guid;}
    bool operator () (const SUserItem& item)
    {
        return item.soldier_guid == guid;
    }
};


namespace soldier
{

uint16 GetIndex( std::map< uint32, SUserSoldier >& soldier_map )
{
    std::vector< uint16 > index_list;
    for ( std::map< uint32, SUserSoldier >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        index_list.push_back( iter->second.soldier_index );
    }
    std::sort(index_list.begin(), index_list.end());

    uint32 index = 0;
    for (std::vector<uint16>::iterator iter = index_list.begin();
        iter != index_list.end();
        iter++)
    {
        if (index != *iter)
            break;
        ++index;
    }
    return index;
}

uint32 GetGuid(SUser *puser)
{
    //将已用guid压放置used_guid_map
    std::map< uint32, bool > guid_map;
    std::map< uint32, std::map< uint32, SUserSoldier> > &soldier_map = puser->data.soldier_map;
    for ( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        for ( std::map< uint32, SUserSoldier >::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            guid_map[ jter->second.guid ] = true;
        }
    }

    //顺序查找没有使用的guid
    uint32 guid = 1;
    for ( std::map< uint32, bool >::iterator iter = guid_map.begin();
        iter != guid_map.end();
        ++iter,++guid )
    {
        if ( iter->first != guid )
            break;
    }
    return guid;
}

uint32 GetSoldierStar(SUser *puser, uint32 soldier_id)
{
    std::map< uint32, SUserSoldier >&soldier_map = puser->data.soldier_map[kSoldierTypeCommon];
    for ( std::map< uint32, SUserSoldier >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
            if ( iter->second.soldier_id == soldier_id )
                return iter->second.star;
    }

    return 0;
}

bool CheckSoldier( SUser *puser, uint32 soldier_id )
{
    std::map< uint32, std::map< uint32, SUserSoldier > > &soldier_map = puser->data.soldier_map;
    for ( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        for ( std::map< uint32, SUserSoldier >::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            if ( jter->second.soldier_id == soldier_id )
                return true;
        }
    }
    return false;
}

bool CheckSoldierGuid( SUser *puser, uint32 guid )
{
    std::map< uint32, std::map< uint32, SUserSoldier > > &soldier_map = puser->data.soldier_map;
    for ( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        for ( std::map< uint32, SUserSoldier >::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            if ( jter->second.guid == guid )
                return true;
        }
    }
    return false;
}


void ReplyList(SUser* puser, uint32 soldier_type)
{
    PRSoldierList rep;
    rep.soldier_type = soldier_type;
    rep.soldier_map = puser->data.soldier_map[ soldier_type ];

    bccopy(rep, puser->ext);
    local::write(local::access, rep);
}

void Add(SUser* puser, uint32 soldier_id, uint32 path, uint32 count )
{
    MacorCheckSoldierId(psoldier, soldier_id);
    std::map< uint32, SUserSoldier > &soldier_map = puser->data.soldier_map[ kSoldierTypeCommon ];

    //查找是否已经存在
    if ( CheckSoldier( puser, soldier_id ) )        //存在
    {
        coin::give( puser, psoldier->exist_give, path );
    }
    else
    {
        SUserSoldier soldier;
        soldier.guid            = GetGuid(puser);
        soldier.soldier_type    = kSoldierTypeCommon;
        soldier.soldier_index   = GetIndex( soldier_map );
        soldier.soldier_id      = psoldier->id;
        soldier.level           = 1;
        soldier.quality         = kSoldierQualityInitLv;
        soldier.quality_lv      = kSoldierQualityInitLv;
        soldier.star            = psoldier->star;

        //添加的武将在一定级别之内等级和主角等级相同
        uint32 level = theGlobalExt.get<uint32>("team_up_soldier_up_level");
        if( puser->data.simple.team_level <= level )
        {
            CLevelData::SData *plevel = theLevelExt.Find(puser->data.simple.team_level);
            if( NULL == plevel )
                return;

            soldier.level = plevel->soldier_lv;
        }

        soldier_map[ soldier.guid ] = soldier;

        ReplySet(puser, soldier, kObjectAdd, path);

        S2UInt32 _soldier;
        _soldier.first = soldier.soldier_type;
        _soldier.second = soldier.guid;

        event::dispatch( SEventFightExtAbleAllUpdate( puser, path ) );

        //货币事件
        event::dispatch( SEventCoin( puser, path, kCoinSoldier, soldier_id, 1, kObjectAdd, 0 ) );
    }
}

void ReplySet(SUser *puser, SUserSoldier &soldier, uint32 set_type, uint32 path )
{
    PRSoldierSet rep;
    rep.set_type = set_type;
    rep.set_path = path;
    rep.soldier = soldier;
    bccopy( rep, puser->ext );
    local::write( local::access, rep );
}

void TakeGuid(SUser* puser, S2UInt32 soldier, uint32 path)
{
    MacroCheckSoldierGuid(soldier);

    ReplySet(puser, soldier_iter->second, kObjectDel, path);
    soldier_map.erase(soldier_iter);
    return;
}

void TakeId(SUser* puser, uint32 soldier_id, uint32 path, uint32 count)
{
    for( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = puser->data.soldier_map.begin();
        iter != puser->data.soldier_map.end();
        ++iter )
    {
        std::map< uint32, SUserSoldier >& soldier_map = iter->second;
        for ( std::map< uint32, SUserSoldier >::iterator jter = soldier_map.begin(); jter!=soldier_map.end(); )
        {
            if ( 0 == count )
                return;

            if ( jter->second.soldier_id != soldier_id )
            {
                jter++;
                continue;
            }

            ReplySet( puser, jter->second, kObjectDel, path );

            //货币事件
            event::dispatch( SEventCoin( puser, path, kCoinSoldier, soldier_id, 1, kObjectDel, 0 ) );

            soldier_map.erase( jter++ );
            --count;
        }
    }
    return;
}

void Move(SUser* puser, S2UInt32 soldier, S2UInt32 index, uint32 path )
{
    MacroCheckSoldierGuid(soldier);
    std::map< uint32, SUserSoldier > &des_soldier_map = puser->data.soldier_map[ index.first ];
    std::map< uint32, SUserSoldier >::iterator iter_dst = des_soldier_map.find( index.second );
    if(iter_dst == des_soldier_map.end() )
    {
        iter_dst->second.soldier_index = soldier_iter->second.soldier_index;
        ReplySet(puser, iter_dst->second, kObjectUpdate, path);
    }
    soldier_iter->second.soldier_index = index.second;
    ReplySet( puser, soldier_iter->second, kObjectUpdate, path );
    return;
}

void AddQualityXp(SUser* puser, S2UInt32 soldier, std::vector<S3UInt32>& coin_list )
{
    MacroCheckSoldierGuid(soldier);

    uint32 quality_lv = soldier_iter->second.quality;
    uint32 quality_xp = soldier_iter->second.quality_xp;

    //当前升一级所需要的xp
    CSoldierQualityData::SData *pdata = theSoldierQualityExt.Find( quality_lv );
    if ( NULL == pdata )
        return;

    //判断是不是正好需要的经验
    CSoldierQualityData::SData *pquality_data = theSoldierQualityExt.Find( quality_lv+1 );
    if ( NULL == pquality_data)
    {
        HandleErrCode( puser, kErrSoldierQualityNotExist, 0 );
        return;
    }

    //不能超过最大经验
    uint32 max_xp = 0;
    uint32 temp_quality_lv = quality_lv;
    while(true)
    {
        CSoldierQualityData::SData *pquality_data = theSoldierQualityExt.Find( temp_quality_lv+1 );
        if( NULL == pquality_data )
            break;
        max_xp += pquality_data->xp;
        temp_quality_lv++;
    }

    //如果是空列表直接返回
    if (coin_list.empty())
        return;

    //当前物品提供的xp
    std::vector<S3UInt32> del_coin_list;
    for( std::vector<S3UInt32>::iterator iter = coin_list.begin();
        iter != coin_list.end();
        ++iter )
    {
        //判断是不是所需要的材料
        CSoldierQualityXpData::SData *pdata = theSoldierQualityXpExt.Find( *iter );
        if ( NULL == pdata )
        {
            HandleErrCode( puser, kErrSoldierQualityXpCoinNoExist, 0 );
            return;
        }
        //如果超过上限
        if ( quality_xp + pdata->quality_xp * (iter->val/pdata->coin.val) > max_xp )
        {
            S3UInt32 del_coin = *iter;
            while(del_coin.val > 0)
            {
                if ( quality_xp + pdata->quality_xp * ((del_coin.val-1)/pdata->coin.val) < max_xp )
                {
                    quality_xp += pdata->quality_xp * (del_coin.val/pdata->coin.val);
                    del_coin_list.push_back(del_coin);
                    break;
                }
            }
            if ( quality_xp > max_xp )
                break;
        }
        else
        {
            quality_xp += pdata->quality_xp * (iter->val/pdata->coin.val);
            del_coin_list.push_back(*iter);
        }
    }

    //物品检查
    uint32 check_res = coin::check_take( puser, del_coin_list);
    if ( 0 != check_res )
    {
        //coin::reply_lack( puser, check_res );
        return;
    }

    //删除物品
    coin::take( puser, del_coin_list, kPathSoldierQualityXpAdd );

    //设置武将品质经验
    soldier_iter->second.quality_xp = quality_xp;

    ReplySet( puser, soldier_iter->second, kObjectUpdate, kPathSoldierQualityXpAdd );
}

//(等级基础属性*星级成长*英雄属性偏向+(神殿组合属性+神殿英雄收集属性+图腾收集属性+神符属性+其他暂定系统1)*英雄属性偏向
bool GetSoldierBaseExt(SUser* puser, S2UInt32 soldier, SFightExtAble &base_able)
{
    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[(soldier).first];
    std::map< uint32, SUserSoldier >::iterator iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == iter)
    {
        HandleErrCode(puser, kErrSoldierGuidNotExist, 0);
        return false;
    }

    CSoldierData::SData* psoldier = theSoldierExt.Find( iter->second.soldier_id );
    if ( NULL == psoldier )
    {
        HandleErrCode( puser, kErrSoldierDataNotExist, iter->second.soldier_id );
        return false;
    }

    CSoldierBaseData::SData *psoldierbase = theSoldierBaseExt.Find( iter->second.soldier_id );
    if ( NULL == psoldierbase)
        return false;

    CSoldierLvData::SData *psoldierlv = theSoldierLvExt.Find( iter->second.level );
    if ( NULL == psoldierlv)
        return false;

    CSoldierStarData::SData *psoldierstar = theSoldierStarExt.Find( iter->second.star );
    if ( NULL == psoldierstar )
        return false;

    CSoldierQualityData::SData *psoldier_quality = theSoldierQualityExt.Find( iter->second.quality );
    if ( NULL == psoldier_quality )
        return false;

    //等级基础属性*星级成长*英雄属性偏向 6项基本属性
    //等级基础属性 + 英雄属性偏向 百分比属性
    SFightExtAble able;
    able.hp  = (uint32)((psoldierlv->hp * (psoldierstar->grow/10000.0)+  psoldier_quality->hp) * psoldierbase->hp/10000.0);
    able.physical_ack  = (uint32)((psoldierlv->physical_ack * (psoldierstar->grow/10000.0) + psoldier_quality->physical_ack) * psoldierbase->physical_ack/10000.0);
    able.physical_def  = (uint32)((psoldierlv->physical_def * (psoldierstar->grow/10000.0) + psoldier_quality->physical_def) * psoldierbase->physical_def/10000.0);
    able.magic_ack  = (uint32)((psoldierlv->magic_ack * (psoldierstar->grow/10000.0) + psoldier_quality->magic_ack) * psoldierbase->magic_ack/10000.0);
    able.magic_def  = (uint32)((psoldierlv->magic_def * (psoldierstar->grow/10000.0) + psoldier_quality->magic_def) * psoldierbase->magic_def/10000.0);
    able.speed  = (uint32)((psoldierlv->speed * (psoldierstar->grow/10000.0)  + psoldier_quality->speed) * psoldierbase->speed/10000.0);
    able.critper  = (uint32)(psoldierlv->critper * (psoldierbase->critper/10000.0));
    able.crithurt  = (uint32)(psoldierlv->crithurt * (psoldierbase->crithurt/10000.0));
    able.critper_def  = (uint32)(psoldierlv->critper_def * (psoldierbase->critper_def/10000.0));
    able.crithurt_def  = (uint32)(psoldierlv->crithurt_def * (psoldierbase->crithurt_def/10000.0));
    able.recover_critper  = (uint32)(psoldierlv->recover_critper * (psoldierbase->recover_critper/10000.0));
    able.recover_critper_def  = (uint32)(psoldierlv->recover_critper_def * (psoldierbase->recover_critper_def/10000.0));
    able.hitper  = (uint32)(psoldierlv->hitper + (psoldierlv->hitper-10000)*((psoldierbase->hitper-10000)/10000.0));
    able.dodgeper  = (uint32)(psoldierlv->dodgeper * (psoldierbase->dodgeper/10000.0));
    able.parryper  = (uint32)(psoldierlv->parryper * (psoldierbase->parryper/10000.0));
    able.parryper_dec  = (uint32)(psoldierlv->parryper_dec * (psoldierbase->parryper_dec/10000.0));
    able.recover_add_fix  = (uint32)(psoldierlv->recover_add_fix * (psoldierbase->recover_add_fix/10000.0));
    able.recover_del_fix  = (uint32)(psoldierlv->recover_del_fix * (psoldierbase->recover_del_fix/10000.0));
    able.recover_add_per  = (uint32)(psoldierlv->recover_add_per * (psoldierbase->recover_add_per/10000.0));
    able.recover_del_per  = (uint32)(psoldierlv->recover_del_per * (psoldierbase->recover_del_per/10000.0));
    able.rage_add_fix  = (uint32)(psoldierlv->rage_add_fix * (psoldierbase->rage_add_fix/10000.0));
    able.rage_del_fix  = (uint32)(psoldierlv->rage_del_fix * (psoldierbase->rage_del_fix/10000.0));
    able.rage_add_per  = (uint32)(psoldierlv->rage_add_per * (psoldierbase->rage_add_per/10000.0));
    able.rage_del_per  = (uint32)(psoldierlv->rage_del_per * (psoldierbase->rage_del_per/10000.0));

    SFightExtAble other_able;
    other_able = temple::GetTempleExt(puser, iter->second, base_able );


    other_able.hp  = (uint32)(other_able.hp * psoldierbase->hp/10000.0);
    other_able.physical_ack  = (uint32)(other_able.physical_ack * psoldierbase->physical_ack/10000.0);
    other_able.physical_def  = (uint32)(other_able.physical_def * psoldierbase->physical_def/10000.0);
    other_able.magic_ack  = (uint32)(other_able.magic_ack * psoldierbase->magic_ack/10000.0);
    other_able.magic_def  = (uint32)(other_able.magic_def * psoldierbase->magic_def/10000.0);
    other_able.speed  = (uint32)(other_able.speed * psoldierbase->speed/10000.0);

    base_able = theEffectExt.AddFightExtAble(able, other_able);

    return true;
}

bool GetBaseExt(SUser* puser, S2UInt32 soldier, SFightExtAble &able )
{
    if ( !GetSoldierBaseExt( puser, soldier, able ) )
        return false;

    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[(soldier).first];
    std::map< uint32, SUserSoldier >::iterator iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == iter)
    {
        HandleErrCode(puser, kErrSoldierGuidNotExist, 0);
        return false;
    }

    //装备
    SFightExtAble extra_able;
    SFightExtAble item_able = equip::GetFightExt(puser, iter->second, able);
    extra_able = theEffectExt.AddFightExtAble( extra_able, item_able );

    able = theEffectExt.AddFightExtAble( able, extra_able);
    return true;
}

void ReplySoldierEquipExt(SUser *puser, S2UInt32 soldier )
{
    PRSoldierEquipExt rep;
    rep.soldier = soldier;
    bccopy( rep, puser->ext );
    if ( !GetSoldierBaseExt( puser, soldier, rep.able ) )
        return;

    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[(soldier).first];
    std::map< uint32, SUserSoldier >::iterator iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == iter)
    {
        HandleErrCode(puser, kErrSoldierGuidNotExist, 0);
        return;
    }

    rep.able = equip::GetFightExt(puser, iter->second, rep.able);
    local::write( local::access, rep );
}

bool GetSoldierExt(SUser* puser, S2UInt32 soldier, SFightExtAble &dst_able )
{
    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[(soldier).first];
    std::map< uint32, SUserSoldier >::iterator iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == iter)
    {
        HandleErrCode(puser, kErrSoldierGuidNotExist, 0);
        return false;
    }

    CSoldierData::SData* psoldier = theSoldierExt.Find( iter->second.soldier_id );
    if ( NULL == psoldier )
    {
        HandleErrCode( puser, kErrSoldierDataNotExist, iter->second.soldier_id );
        return false;
    }

    CSoldierBaseData::SData *psoldierbase = theSoldierBaseExt.Find( iter->second.soldier_id );
    if ( NULL == psoldierbase)
        return false;

    CSoldierLvData::SData *psoldierlv = theSoldierLvExt.Find( iter->second.level );
    if ( NULL == psoldierlv)
        return false;

    CSoldierStarData::SData *psoldierstar = theSoldierStarExt.Find( iter->second.star );
    if ( NULL == psoldierstar )
        return false;

    CSoldierQualityData::SData *psoldier_quality = theSoldierQualityExt.Find( iter->second.quality );
    if ( NULL == psoldier_quality )
        return false;

    //获取基础属性
    SFightExtAble able;
    SFightExtAble extra_able;
    GetBaseExt(puser, soldier, able);

    //品质提升装备属性
    SFightExtAble quality_able = soldier::GetQualityExt(puser, soldier, able);
    extra_able = theEffectExt.AddFightExtAble( extra_able, quality_able );

    //品质当前装备
    SFightExtAble quality_able_cur = equip::GetFightExtSkill(puser, iter->second, able);
    extra_able = theEffectExt.AddFightExtAble( extra_able, quality_able_cur );

    //被动技能百分比
    SFightExtAble passive_able_add;
    SFightExtAble passive_able_del;
    std::vector<SSoldierSkill> &skill_list = iter->second.skill_list;
    uint32 count = 1;
    for( std::vector<S2UInt32>::iterator iter = psoldier->odds.begin();
        iter != psoldier->odds.end();
        ++iter,++count )
    {
        uint32 level = iter->second;
        std::vector<SSoldierSkill>::iterator jter = std::find_if( skill_list.begin(), skill_list.end(), Soldier_EqualSkillID( iter->first ));

        if ( jter != skill_list.end() )
            level = jter->level;

        COddData::SData *podd = theOddExt.Find( iter->first, level );
        if ( NULL == podd )
            continue;

        //如果超过数量就break
        if ( count > psoldier_quality->skill_active )
            break;
        if ( 0 != podd->effect.cate )
        {
            SFightExtAble temp = theEffectExt.ToFightExtAble( podd->effect.cate, able, podd->effect.objid);
            if ( kFightEffectTypeBuff == podd->effect.val )
            {
                passive_able_add = theEffectExt.AddFightExtAble( passive_able_add, temp );
            }
            else if ( kFightEffectTypeDebuff == podd->effect.val )
            {
                passive_able_del = theEffectExt.AddFightExtAble( passive_able_del, temp );
            }
        }
    }
    extra_able = theEffectExt.AddFightExtAble( extra_able, passive_able_add );
    extra_able = theEffectExt.SubFightExtAble( extra_able, passive_able_del );

    dst_able = theEffectExt.AddFightExtAble( able, extra_able );
    return true;
}

SFightExtAble GetQualityExt( SUser* puser, S2UInt32 soldier, SFightExtAble& able )
{
    SFightExtAble extra_able;
    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[(soldier).first];
    std::map< uint32, SUserSoldier >::iterator iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == iter)
    {
        HandleErrCode(puser, kErrSoldierGuidNotExist, 0);
        return extra_able;
    }

    CSoldierData::SData* psoldier = theSoldierExt.Find( iter->second.soldier_id );
    if ( NULL == psoldier )
    {
        HandleErrCode( puser, kErrSoldierDataNotExist, iter->second.soldier_id );
        return extra_able;
    }

    if ( iter->second.quality >= 2 )
    {
        for( int32 i = 1; i < iter->second.quality; ++i )
        {
            CSoldierQualityOccuData::SData *poccu_data = theSoldierQualityOccuExt.Find( i, psoldier->occupation );
            if ( NULL == poccu_data )
                continue;
            if ( kCoinItem != poccu_data->cost.cate )
                continue;

            CItemData::SData *p_itemdata = theItemExt.Find(poccu_data->cost.objid);
            if (NULL == p_itemdata)
                continue;

            for (std::vector<S2UInt32>::iterator jter = p_itemdata->attrs.begin();
                jter != p_itemdata->attrs.end();
                ++jter )
            {
                SFightExtAble temp = theEffectExt.ToFightExtAble(jter->first, able, jter->second);
                extra_able = theEffectExt.AddFightExtAble(extra_able, temp);
            }
        }
    }

    return extra_able;
}

bool GetSoldier(SUser *puser, uint32 guid, SUserSoldier &soldier, uint32 kType )
{
    if ( 0 == kType )
    {
        std::map< uint32, std::map< uint32, SUserSoldier > > &soldier_map = puser->data.soldier_map;
        for ( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = soldier_map.begin();
            iter != soldier_map.end();
            ++iter )
        {
            for ( std::map< uint32, SUserSoldier >::iterator jter = iter->second.begin();
                jter != iter->second.end();
                ++jter )
            {
                if ( jter->second.guid == guid )
                {
                    soldier = jter->second;
                    return true;
                }
            }
        }
    }
    else
    {
        std::map< uint32, SUserSoldier > &soldier_list = puser->data.soldier_map[kType];
        for ( std::map< uint32, SUserSoldier >::iterator iter = soldier_list.begin();
            iter != soldier_list.end();
            ++iter )
        {
            if ( iter->second.guid == guid )
            {
                soldier = iter->second;
                return true;
            }
        }
    }
    return false;
}

void GetSoldierSkill(SUser *puser, uint32 guid, uint32 soldier_type, std::vector<SFightSkill> &skill_list )
{
    SFightSkill fight_skill;
    SUserSoldier soldier;
    if ( !GetSoldier( puser, guid, soldier, soldier_type ) )
        return;
    CSoldierData::SData *psoldier = theSoldierExt.Find( soldier.soldier_id );
    if ( NULL == psoldier )
        return;
    skill_list.clear();

    uint32 index = 1;
    for( std::vector<S2UInt32>::iterator iter = psoldier->skills.begin();
        iter != psoldier->skills.end();
        ++iter, ++index )
    {
        if ( 0 == iter->first )
            continue;
        fight_skill.skill_id = iter->first;
        fight_skill.skill_level = iter->second;

        //如果是怒气技能
        if ( 2 == index )
        {
            if( soldier.quality >= 2 )
            {
                std::vector<SSoldierSkill> &skill_list = soldier.skill_list;
                std::vector<SSoldierSkill>::iterator jter = std::find_if( skill_list.begin(), skill_list.end(), Soldier_EqualSkillID( fight_skill.skill_id  ));

                if ( jter != skill_list.end() )
                {
                    fight_skill.skill_level = jter->level;
                }
            }
            else
            {
                fight_skill.skill_id = skill_list[0].skill_id;
                fight_skill.skill_level = skill_list[0].skill_level;
            }
        }

        //如果是觉醒技能
        if ( 3 == index )
        {
            CSoldierQualityData::SData *pquality_data = theSoldierQualityExt.Find( soldier.quality );
            if ( NULL != pquality_data )
            {
                fight_skill.skill_level = pquality_data->disillusion_skill_level;
            }
        }

        skill_list.push_back(fight_skill);
    }
}

void GetSoldierOdd(SUser *puser, uint32 guid, uint32 soldier_type, uint32 index, std::vector<SFightOdd> &odd_list )
{
    SUserSoldier soldier;
    if ( !GetSoldier( puser, guid, soldier, soldier_type ) )
        return;
    CSoldierData::SData *psoldier = theSoldierExt.Find( soldier.soldier_id );
    if ( NULL == psoldier )
        return;
    odd_list.clear();

    CSoldierQualityData::SData *psoldier_quality = theSoldierQualityExt.Find( soldier.quality );
    if ( NULL == psoldier_quality )
        return;

    uint32 count = 1;
    for( std::vector<S2UInt32>::iterator iter = psoldier->odds.begin();
        iter != psoldier->odds.end();
        ++iter,++count )
    {
        uint32 level = iter->second;
        std::vector<SSoldierSkill> &skill_list = soldier.skill_list;
        std::vector<SSoldierSkill>::iterator jter = std::find_if( skill_list.begin(), skill_list.end(), Soldier_EqualSkillID( iter->first ));

        if ( jter != skill_list.end() )
            level = jter->level;

        COddData::SData *podd = theOddExt.Find( iter->first, level );
        if ( NULL == podd )
            continue;

        //如果超过数量就break
        if ( count > psoldier_quality->skill_active )
            break;
        SFightOdd fight_odd;
        fight_odd.id = iter->first;
        fight_odd.level = iter->second;
        fight_odd.start_round = 0;
        fight_odd.status_id = podd->status.cate;
        fight_odd.status_value = podd->status.objid;
        odd_list.push_back(fight_odd);
    }

    // 装备
    equip::AddOdd(puser, soldier, odd_list);

    // 神殿套装
    temple::AddTempleOdd(puser, soldier, odd_list);
}

uint32 GetSoldierRage(SUser *puser, uint32 guid)
{
    SUserSoldier soldier;
    if ( !GetSoldier( puser, guid, soldier ) )
        return 0;

    CSoldierBaseData::SData *psoldierbase = theSoldierBaseExt.Find( soldier.soldier_id );
    if ( NULL == psoldierbase)
        return false;

    return psoldierbase->initial_rage;
}

void QualityUp( SUser* puser, S2UInt32 soldier )
{
    MacroCheckSoldierGuid(soldier);

    CSoldierQualityData::SData *pdata = theSoldierQualityExt.Find( soldier_iter->second.quality );
    if ( NULL == pdata )
    {
        HandleErrCode(puser, kErrSoldierQualityNotExist, 0);
        return;
    }

    //等级限制
    /*这个等级限制取消 换成另外一种等级限制
    if ( soldier_iter->second.level < pdata->lv_limit )
    {
        //HandleErrCode(puser, kErrSoldierQualityLvLimit, 0);
        return;
    }
    */
    CSoldierData::SData *psoldier_data = theSoldierExt.Find( soldier_iter->second.soldier_id );
    if ( NULL == psoldier_data )
        return;

    CSoldierQualityOccuData::SData *poccu_data = theSoldierQualityOccuExt.Find( soldier_iter->second.quality, psoldier_data->occupation );
    if( NULL == poccu_data )
    {
        HandleErrCode(puser, kErrSoldierQualityNotExist, 0);
        return;
    }

    //升级条件检查
    if ( soldier_iter->second.quality_xp < pdata->xp )
    {
        //HandleErrCode(puser, kErrSoldierLvNotXp, 0 );
        return;
    }

    //升级条件检查
    ItemList &equip_list = puser->data.item_map[kBagFuncSoldierEquipSkill];
    ItemList::iterator src_iter = std::find_if(equip_list.begin(), equip_list.end(), SEqualItemSoldierGuid(soldier_iter->second.guid));
    if (src_iter == equip_list.end())
        return;

    CSoldierQualityData::SData *pnext_data = theSoldierQualityExt.Find( soldier_iter->second.quality + 1 );
    if ( NULL == pnext_data )
    {
        HandleErrCode(puser, kErrSoldierQualityNotExist, 0);
        return;
    }

    //扣除物品
    S2UInt32 cost_item;
    cost_item.first = kBagFuncSoldierEquipSkill;
    cost_item.second = src_iter->guid;
    item::DelItemByGuid(puser, cost_item, 1, kPathSoldierQualityUp );

    uint32 old_quality = soldier_iter->second.quality;
    soldier_iter->second.quality++;
    soldier_iter->second.quality_xp = soldier_iter->second.quality_xp - pdata->xp;

    event::dispatch( SEventSoldierQualityUp( puser, soldier_iter->second.soldier_id, old_quality, kPathSoldierQualityUp ));
    event::dispatch( SEventFightExtAbleSoldierUpdate( puser, soldier, kPathSoldierQualityUp ) );

    ReplySet( puser, soldier_iter->second, kObjectUpdate, kPathSoldierQualityUp );
}

void QualityUp( SUser* puser )
{
    std::map<uint32, SUserSoldier> &soldier_list = puser->data.soldier_map[kSoldierTypeCommon];
    for( std::map<uint32, SUserSoldier>::iterator soldier_iter = soldier_list.begin();
        soldier_iter != soldier_list.end();
        ++soldier_iter )
    {
        CSoldierQualityData::SData *pnext_data = theSoldierQualityExt.Find( soldier_iter->second.quality + 1 );
        if ( NULL == pnext_data )
            continue;
        soldier_iter->second.quality++;
        ReplySet( puser, soldier_iter->second, kObjectUpdate, kPathSoldierQualityUp );
    }
}

void LvUp( SUser* puser, S2UInt32 soldier )
{
    MacroCheckSoldierGuid(soldier);

    //条件判断
    CSoldierLvData::SData *pdata = theSoldierLvExt.Find( soldier_iter->second.level );
    if ( NULL == pdata )
        return;
    CSoldierLvData::SData *pnext_data = theSoldierLvExt.Find( soldier_iter->second.level + 1 );
    if ( NULL == pnext_data )
    {
        HandleErrCode(puser, kErrSoldierLvNotExist, 0);
        return;
    }

    //品质限制
    /*
    CSoldierQualityData::SData *pquality_data = theSoldierQualityExt.Find( soldier_iter->second.quality );
    if ( NULL == pquality_data )
    {
        HandleErrCode(puser, kErrSoldierQualityNotExist, 0);
        return;
    }

    if ( soldier_iter->second.level >= pquality_data->soldier_lv )
    {
        HandleErrCode(puser, kErrSoldierQualityLevel, 0 );
        return;
    }
    */

    //不能超过战队等级
    CLevelData::SData *plevel = theLevelExt.Find(puser->data.simple.team_level);
    if( NULL == plevel )
        return;
    if ( soldier_iter->second.level >= plevel->soldier_lv )
    {
        //HandleErrCode(puser, kErrSoldierTeamLevel, 0);
        return;
    }

    //升级条件检查
    uint32 ret = coin::check_take( puser, pdata->cost );
    if ( ret != 0 )
    {
        coin::reply_lack( puser, ret );
        return;
    }

    //扣除物品
    coin::take( puser, pdata->cost, kPathSoldierLvUp );

    uint32 old_level = soldier_iter->second.level;
    soldier_iter->second.level++;

    event::dispatch( SEventSoldierLvUp( puser, soldier_iter->second.soldier_id, old_level, kPathSoldierLvUp ) );
    event::dispatch( SEventFightExtAbleSoldierUpdate( puser, soldier, kPathSoldierLvUp ) );

    ReplySet( puser, soldier_iter->second, kObjectUpdate, kPathSoldierLvUp );
}

void LvUpToTeam( SUser* puser )
{
    std::map<uint32, SUserSoldier> &soldier_map = puser->data.soldier_map[kSoldierTypeCommon];

    for( std::map<uint32, SUserSoldier>::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {

        CLevelData::SData *plevel = theLevelExt.Find(puser->data.simple.team_level);
        if( NULL == plevel )
            return;

        if ( iter->second.level < plevel->soldier_lv )
        {
            uint32 old_level = iter->second.level;
            iter->second.level = plevel->soldier_lv;
            event::dispatch( SEventSoldierLvUp( puser, iter->second.soldier_id, old_level, kPathSoldierLvUp ) );
        }
    }

    event::dispatch( SEventFightExtAbleAllUpdate( puser, kPathSoldierLvUp ) );

    ReplyList( puser, kSoldierTypeCommon);
}

void StarUp( SUser* puser, S2UInt32 soldier )
{
    MacroCheckSoldierGuid(soldier);
    MacorCheckSoldierId(psoldier, soldier_iter->second.soldier_id);

    //条件判断
    CSoldierStarData::SData *pdata = theSoldierStarExt.Find( soldier_iter->second.star );
    if ( NULL == pdata )
        return;
    CSoldierStarData::SData *pnext_data = theSoldierStarExt.Find( soldier_iter->second.star + 1 );
    if ( NULL == pnext_data )
    {
        HandleErrCode(puser, kErrSoldierStarNotExist, 0);
        return;
    }

    std::vector<S3UInt32> cost_list;

    S3UInt32 cost = psoldier->star_cost;
    cost.val = pdata->cost;
    cost_list.push_back( cost );
    cost_list.push_back( pdata->need_money );

    //升级条件检查
    uint32 ret = coin::check_take( puser, cost_list );
    if ( ret != 0 )
    {
        coin::reply_lack( puser, ret );
        return;
    }

    //扣除物品
    coin::take( puser, cost_list, kPathSoldierStarUp );

    uint32 old_star = soldier_iter->second.star;
    soldier_iter->second.star++;

    event::dispatch( SEventSoldierStarUp( puser, soldier_iter->second.soldier_id, old_star, kPathSoldierStarUp ));
    event::dispatch( SEventFightExtAbleSoldierUpdate( puser, soldier, kPathSoldierStarUp ) );

    ReplySet( puser, soldier_iter->second, kObjectUpdate, kPathSoldierStarUp );
}

void Recruit( SUser* puser, uint32 id )
{
    CSoldierRecruitData::SData *pdata = theSoldierRecruitExt.Find( id );
    if ( NULL == pdata )
        return;

    std::map< uint32, SUserSoldier > &soldier_map = puser->data.soldier_map[ kSoldierTypeCommon ];
    for( std::map< uint32, SUserSoldier >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        if ( iter->second.soldier_id == pdata->soldier_id )
        {
            HandleErrCode( puser, kErrSoldierHave, 0 );
            return;
        }
    }

    //升级条件检查
    uint32 ret = coin::check_take( puser, pdata->cost_ );
    if ( ret != 0 )
    {
        coin::reply_lack( puser, ret );
        return;
    }

    //扣除物品
    coin::take( puser, pdata->cost_, kPathSoldierLvUp );

    Add( puser, pdata->soldier_id, kPathSoldierRecruit );

    PRSoldierRecruit rep;
    rep.id = id;
    bccopy( rep, puser->ext );
    local::write( local::access, rep );
}

void Equip(SUser* puser, S2UInt32 soldier, S2UInt32 item)
{

}

uint32 GetSkillPoint( SUser *puser, S2UInt32 soldier )
{
    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[ (soldier).first ];
    std::map< uint32, SUserSoldier >::iterator soldier_iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == soldier_iter)
        return 0;

    uint32 point = 0;
    std::vector<SSoldierSkill> &skill_list = soldier_iter->second.skill_list;

    for( std::vector<SSoldierSkill>::iterator iter = skill_list.begin();
        iter != skill_list.end();
        ++iter )
    {
        if ( iter->level > 1 )
            point += iter->level-1;
    }

    return point;
}

uint32 GetSkillPointMax( SUser *puser, S2UInt32 soldier )
{
    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[ (soldier).first ];
    std::map< uint32, SUserSoldier >::iterator soldier_iter = soldier_map.find( (soldier).second );
    if (soldier_map.end() == soldier_iter)
        return 0;

    CSoldierQualityData::SData *pdata = theSoldierQualityExt.Find( soldier_iter->second.quality );
    if ( NULL == pdata )
        return 0;

    return pdata->skill_point;
}

void SkillReset(SUser* puser, S2UInt32 soldier )
{
    MacroCheckSoldierGuid(soldier);

    uint32 point = GetSkillPoint( puser, soldier );

    S3UInt32 cost;
    cost.cate = kCoinGold;
    cost.val = point * theGlobalExt.get<uint32>("soldier_skill_reset_cost");

    //升级条件检查
    uint32 ret = coin::check_take( puser, cost );
    if ( ret != 0 )
    {
        coin::reply_lack( puser, ret );
        return;
    }

    //扣除物品
    coin::take( puser, cost, kPathSoldierSkillReset );

    //重置
    soldier_iter->second.skill_list.clear();

    ReplySet(puser, soldier_iter->second, kObjectUpdate, kPathSoldierSkillReset);
}

void SkillLvUp(SUser* puser, S2UInt32 soldier, uint32 skill_id)
{
    MacroCheckSoldierGuid(soldier);

    std::vector<SSoldierSkill> &skill_list = soldier_iter->second.skill_list;

    uint32 point = GetSkillPoint( puser, soldier );
    uint32 point_max = GetSkillPointMax( puser, soldier );

    //技能点是否足够
    if ( point >= point_max )
    {
        HandleErrCode(puser, kErrSoldierNoSkillPoint, 0 );
        return;
    }

    std::vector<SSoldierSkill>::iterator jter = std::find_if( skill_list.begin(), skill_list.end(), Soldier_EqualSkillID( skill_id ));

    if ( jter == skill_list.end() )
    {
        SSoldierSkill soldier_skill;
        soldier_skill.id = skill_id;
        soldier_skill.level = 1;
        skill_list.push_back(soldier_skill);
        jter = std::find_if( skill_list.begin(), skill_list.end(), Soldier_EqualSkillID( skill_id ));
    }

    //技能等级不能超过英雄等级
    if( jter->level >= soldier_iter->second.level )
    {
        HandleErrCode(puser, kErrSoldierSkillLvLimit, 0 );
        return;
    }

    jter->level++;
    ReplySet( puser, soldier_iter->second, kObjectUpdate, kPathSoldierSkillLvUp );
}

uint32 GetSoldierCountByQuality(SUser *puser, uint32 quality)
{
    uint32 count = 0;
    std::map< uint32, SUserSoldier > &soldier_map = puser->data.soldier_map[kSoldierTypeCommon];
    for ( std::map< uint32, SUserSoldier >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        if ( iter->second.quality >= quality )
            count++;
    }
    return count;
}

uint32 GetSoldierCount(SUser *puser)
{
    std::map< uint32, SUserSoldier > &soldier_map = puser->data.soldier_map[kSoldierTypeCommon];

    return (uint32)soldier_map.size();
}

uint32 GetSoldierStar(SUser *puser)
{
    uint32 count = 0;
    std::map< uint32, SUserSoldier > &soldier_map = puser->data.soldier_map[kSoldierTypeCommon];
    for ( std::map< uint32, SUserSoldier >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        count += iter->second.star;
    }
    return count;
}

bool GetSoldierOccu(SUser *puser, uint32 guid, uint32 &occu )
{
    std::map< uint32, std::map< uint32, SUserSoldier > > &soldier_map = puser->data.soldier_map;
    for ( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
        for ( std::map< uint32, SUserSoldier >::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            if ( jter->second.guid == guid )
            {
                CSoldierData::SData *psoldier_data =  theSoldierExt.Find( jter->second.soldier_id );
                if ( NULL == psoldier_data )
                    return false;
                occu = psoldier_data->equip_type;
                return true;
            }
        }
    }
    return false;
}

uint32 GetSoldierCountByStar( SUser *puser, uint32 star )
{
    uint32 count = 0;
    std::map< uint32, SUserSoldier >&soldier_map = puser->data.soldier_map[kSoldierTypeCommon];
    for ( std::map< uint32, SUserSoldier >::iterator iter = soldier_map.begin();
        iter != soldier_map.end();
        ++iter )
    {
            if ( iter->second.star >= star )
                ++count;
    }

    return count;
}

std::vector<S3UInt32> ChangeSoldierToOther( SUser *puser, std::vector<S3UInt32> &coins )
{
    std::vector<S3UInt32> change_coins;
    std::map<uint32,uint32> soldier_map;
    for( std::vector<S3UInt32>::iterator iter = coins.begin();
        iter != coins.end();
        ++iter )
    {
        if ( iter->cate != kCoinSoldier )
        {
            change_coins.push_back(*iter);
            continue;
        }

        CSoldierData::SData* pdata = theSoldierExt.Find(iter->objid);
        if( NULL == pdata )
            continue;

        //如果存在 或者不存在但是前面列表出现过
        if(soldier::CheckSoldier(puser, iter->objid) || 0 != soldier_map[iter->objid] )
        {
            S3UInt32 coin = pdata->exist_give;
            coin.val *= iter->val;
            change_coins.push_back(coin);
        }
        //如果不存在并且前面列表没出现过
        else
        {
            S3UInt32 soldier_coin = *iter;
            soldier_coin.val = 1;
            change_coins.push_back( soldier_coin );
            if ( iter->val > 1 )
            {
                S3UInt32 coin = pdata->exist_give;
                coin.val *= iter->val - 1;
                change_coins.push_back(coin);
            }
        }
        soldier_map[iter->objid]++;
    }
    return change_coins;
}

std::vector<std::vector<S3UInt32> > ChangeSoldierToOther( SUser *puser, std::vector<std::vector<S3UInt32> > &coins )
{
    std::vector<std::vector<S3UInt32> > change_coins;
    std::map<uint32,uint32> soldier_map;
    for( std::vector<std::vector<S3UInt32> >::iterator jter = coins.begin();
        jter != coins.end();
        ++jter )
    {
        std::vector<S3UInt32> coin_list;
        for( std::vector<S3UInt32>::iterator iter = jter->begin();
            iter != jter->end();
            ++iter )
        {
            if ( iter->cate != kCoinSoldier )
            {
                coin_list.push_back(*iter);
                continue;
            }

            CSoldierData::SData* pdata = theSoldierExt.Find(iter->objid);
            if( NULL == pdata )
                continue;

            //如果存在 或者不存在但是前面列表出现过
            if(soldier::CheckSoldier(puser, iter->objid) || 0 != soldier_map[iter->objid] )
            {
                S3UInt32 coin = pdata->exist_give;
                coin.val *= iter->val;
                coin_list.push_back(coin);
            }
            //如果不存在并且前面列表没出现过
            else
            {
                S3UInt32 soldier_coin = *iter;
                soldier_coin.val = 1;
                coin_list.push_back( soldier_coin );
                if ( iter->val > 1 )
                {
                    S3UInt32 coin = pdata->exist_give;
                    coin.val *= iter->val - 1;
                    coin_list.push_back(coin);
                }
            }
            soldier_map[iter->objid]++;
        }
        change_coins.push_back(coin_list);
    }
    return change_coins;
}



}// namespace soldier
