#include "command_imp.h"
#include "util.h"
#include "user_imp.h"
#include "user_dc.h"
#include "resource/r_itemext.h"
#include "resource/r_totemext.h"
#include "resource/r_totemglyphext.h"
#include "resource/r_soldierext.h"
#include "resource/r_trialext.h"
#include "resource/r_taskext.h"
#include "item_imp.h"
#include "coin_imp.h"
#include "totem_imp.h"
#include "soldier_imp.h"
#include "gut_imp.h"
#include "var_imp.h"
#include "fight_imp.h"
#include "task_imp.h"
#include "copy_imp.h"
#include "trial_imp.h"
#include "temple_imp.h"
#include "proto/chat.h"
#include "misc.h"
#include "server.h"
#include "jsonconfig.h"
#include "timer.h"
#include "task_event.h"
#include "tomb_imp.h"

namespace command
{

uint32 to_uint(std::string& s)
{
    if (s.empty())
        return 0;
    return strtoul(s.c_str(), NULL, 0);
}

const char* to_str(std::string& s)
{
    return s.c_str();
}

bool Parse(SUser* puser, std::string& content)
{
    //没有权限直接过滤
    //if ( user->static_data.purview == 0 )
    //    return false;

    ////没有后台权限直接过滤
    //if ( !user->CheckBackState( kBackExecutor ) )
    //    return false;

    Tokens tokens   = Split(content, " ");

    if ( tokens.size() < 3 )
        return false;

    if ("$$" != tokens[0])
        return false;

    StrFuncMap::iterator iter = name_func_map.find(tokens[1]);
    if (name_func_map.end() == iter)
        return false;

    //删除 $$, name
    tokens.erase(tokens.begin(), tokens.begin() + 2);
    //return (this->*iter->second)(tokens);

    //只要是 $$ 都不返回聊天消息到客户端
    (*iter->second)(puser,tokens);
    return true;
}

bool ParseRole(SUser *puser, Tokens& tokens)
{
    if ( "add" == tokens[0] )
    {
        if ( tokens.size() < 3 )
            return false;

        S3UInt32 coin;
        coin.val = to_uint(tokens[2]);
        if ("money" == tokens[1])
        {
            coin.cate = kCoinMoney;
        }
        if ("gold" == tokens[1])
        {
            coin.cate = kCoinGold;
        }
        if ("xp" == tokens[1])
        {
            coin.cate = kCoinTeamXp;
        }
        if ("coin" == tokens[1])
        {
            coin.cate = to_uint(tokens[2]);
            coin.objid = to_uint(tokens[3]);
            coin.val = to_uint(tokens[4]);
        }
        if ( 0 != coin.cate )
        {
            coin::give(puser, coin, kPathGameMasterCommand, kCoinFlagOverflow);
            return true;
        }
    }
    else if ( "del" == tokens[0] )
    {
        if ( tokens.size() < 3 )
            return false;

        S3UInt32 coin;
        coin.val = to_uint(tokens[2]);
        if ("money" == tokens[1])
        {
            coin.cate = kCoinMoney;
        }
        if ("gold" == tokens[1])
        {
            coin.cate = kCoinGold;
        }
        if ("xp" == tokens[1])
        {
            coin.cate = kCoinTeamXp;
        }
        if ("coin" == tokens[1])
        {
            coin.cate = to_uint(tokens[2]);
            coin.objid = to_uint(tokens[3]);
            coin.val = to_uint(tokens[4]);
        }

        if ( 0 != coin.cate )
        {
            coin::take(puser, coin, kPathGameMasterCommand);
            return true;
        }
    }
    return false;
}

bool ParseItem(SUser *puser, Tokens& tokens)
{
    if ( "add" == tokens[0] )
    {
        if ( tokens.size() < 3 )
            return false;
        CItemData::SData *item = theItemExt.Find(to_uint(tokens[1]));
        if ( NULL == item )
            return false;

        item::AddItem( puser, to_uint( tokens[1] ), to_uint( tokens[2] ), kPathGameMasterCommand );

        return true;

    }
    return false;
}

bool ParseTask(SUser *puser, Tokens& tokens)
{
    if ( "add" == tokens[0] )
    {
        if ( tokens.size() < 2 )
            return false;

        CTaskData::SData *task = theTaskExt.Find(to_uint(tokens[1]));
        if ( NULL == task )
            return false;

        SUserTask& data = puser->data.task_map[ task->task_id ];
        data.task_id       = task->task_id;
        data.create_time   = server::local_time();

        task::reply_task_set( puser, kObjectAdd, data );

        event::dispatch( SEventTaskAccept( puser, kPathTaskAccept, task->task_id, task, data ) );

        return true;

    }
    if ( "finish" == tokens[0] )
    {
        if ( tokens.size() < 2 )
            return false;

        CTaskData::SData *task = theTaskExt.Find(to_uint(tokens[1]));
        if ( NULL == task )
            return false;

        SUserTask& data = puser->data.task_map[ task->task_id ];
        data.task_id       = task->task_id;
        data.create_time   = server::local_time();

        task::task_finish( puser, to_uint(tokens[1]), false, true );

        return true;

    }
    return false;
}

bool ParseTotem(SUser *puser, Tokens& tokens)
{
    if ( "add" == tokens[0] )
    {
        if ( tokens.size() < 2)
            return false;
        CTotemData::SData *totem = theTotemExt.Find(to_uint(tokens[1]));
        if ( NULL == totem )
            return false;

        totem::Add( puser, to_uint( tokens[1] ), kPathGameMasterCommand );

        return true;
    }
    return false;
}

bool ParseTotemGlyph(SUser *puser, Tokens& tokens)
{
    if ( "add" == tokens[0] )
    {
        if ( tokens.size() < 2)
            return false;
        CTotemGlyphData::SData *glyph = theTotemGlyphExt.Find(to_uint(tokens[1]));
        if ( NULL == glyph )
            return false;

        temple::AddGlyph( puser, to_uint( tokens[1] ), kPathGameMasterCommand );

        return true;
    }
    return false;
}

bool ParseSoldier(SUser *puser, Tokens& tokens)
{
    if ( "add" == tokens[0] )
    {
        if ( tokens.size() < 2)
            return false;
        CSoldierData::SData *soldier = theSoldierExt.Find(to_uint(tokens[1]));
        if ( NULL == soldier )
            return false;

        soldier::Add( puser, to_uint( tokens[1] ), kPathGameMasterCommand );

        return true;
    }
    else if ( "qualityup" == tokens[0] )
    {
        soldier::QualityUp(puser);
        return true;
    }
    return false;
}

bool ParseGut( SUser *puser, Tokens& tokens )
{
    if ( "create" == tokens[0] )
    {
        if ( tokens.size() < 2 )
            return false;

        gut::create( puser, to_uint( tokens[1] ) );

        return true;
    }
    return false;
}

bool ParseVar( SUser *puser, Tokens& tokens )
{
    if ( "set" == tokens[0] )
    {
        if ( tokens.size() < 3 )
            return false;

        var::set( puser, tokens[1], to_uint(tokens[2]), (uint32)server::local_6_time( 0, 1 ) );

        return true;
    }
    return false;
}

bool ParseCopy( SUser* user, Tokens& tokens )
{
    if ( "close" == tokens[0] )
    {
        copy::close( user, true );
        copy::reply_copy_data( user );

        return true;
    }

    return false;
}

bool ParseFight( SUser *puser, Tokens& tokens )
{
    CFight *pcfight = fight::Interface( kFightTypeCommon );
    if ( NULL == pcfight )
        return false;

    SFight * psfight = NULL;
    uint32 target_id = to_uint(tokens[1]);
    if ( "monster" == tokens[0] )
    {
        psfight = pcfight->AddFightToMonster( puser, target_id );
    }
    else if ("player_pve" == tokens[0] )
    {
        psfight = pcfight->AddFightToPlayer( puser, target_id );
    }
    else if ("player" == tokens[0] )
    {

        CFight *pcfight = fight::Interface( kFightTypeCommonPlayer );
        if ( NULL == pcfight )
            return false;
        psfight = pcfight->AddFightToPlayer( puser, target_id );
        if ( NULL == psfight )
            return false;

        //添加Delay
        Json::Value json;
        json["fight_id"] = psfight->fight_id;
        json["seqno"] = psfight->seqno;
        psfight->loop_id = theSysTimeMgr.AddCall( "fight_delay_skill", CJson::Write(json), kFightDelayTime );

        fight::InitFightLua( psfight );
    }
    else if ( "singlearena" == tokens[0] )
    {
        CFight *pcfight = fight::Interface( kFightTypeSingleArenaMonster );
        if ( NULL == pcfight )
            return false;
        psfight = pcfight->AddFightToMonster( puser, target_id );
    }
    else if ( "trial" == tokens[0] )
    {
        CFight *pcfight = fight::Interface( kFightTypeTrialSurvival );
        if ( NULL == pcfight )
            return false;
        puser->ext.trial_id = target_id;

        //判断是否能进入
        CTrialData::SData *pdata = theTrialExt.Find(target_id);
        if ( NULL == pdata )
            return false;

        psfight = pcfight->AddFightToMonster( puser, pdata->monster_id);
    }

    if ( NULL == psfight )
        return false;

    fight::ReplyFightInfo( psfight );

    return false;
}

bool ParseTrial(SUser *puser, Tokens& tokens)
{
    if ( "clear" == tokens[0] )
    {
        trial::TimeLimit(puser);
    }
    return false;
}

bool ParseTomb(SUser *puser, Tokens& tokens)
{
    if ( "test" == tokens[0] )
    {
        tomb::RandomCreate(puser);
        puser->data.tomb_info.try_count = 1;
        puser->data.tomb_info.try_count_now = 1;
        puser->data.tomb_info.win_count = 0;
        puser->data.tomb_info.reward_count = 0;
        puser->data.tomb_info.totem_value_self = 0;
        puser->data.tomb_info.totem_value_target = 0;
        puser->data.soldier_map[kSoldierTypeTombSelf].clear();
        puser->data.soldier_map[kSoldierTypeTombTarget].clear();
        soldier::ReplyList(puser,kSoldierTypeTombSelf);
        soldier::ReplyList(puser,kSoldierTypeTombTarget);
    }
    else if ( "fight" == tokens[0] )
    {
        std::vector<SUserFormation> formation_list = puser->data.formation_map[kFormationTypeCommon];
        if ( to_uint(tokens[1])%(kTombPartCount+1) == 0 )
        {
            SUser *ptarget = theUserDC.find(to_uint(tokens[2]));
            if ( NULL == ptarget )
            {
                theUserDC.query_load(to_uint(tokens[2]), false);
                return false;
            }
        }
        tomb::Fight(puser,to_uint(tokens[1]),to_uint(tokens[2]),formation_list);
    }
    else if ( "reward" == tokens[0] )
    {
        tomb::RewardGet(puser,to_uint(tokens[1]));
    }
    else if ( "reset" == tokens[0] )
    {
        tomb::Reset(puser);
    }
    else if ( "playerreset" == tokens[0] )
    {
        tomb::PlayerReset(puser,to_uint(tokens[1]));
    }
    else if ( "mopup" == tokens[0] )
    {
        tomb::MopUp(puser);
    }
    else if ( "addcount" == tokens[0] )
    {
        puser->data.tomb_info.try_count = 0;
        tomb::ReplyInfo(puser);
    }
    return false;
}

void Build(void)
{
    name_func_map["role"]           = &ParseRole;
    name_func_map["item"]           = &ParseItem;
    name_func_map["task"]           = &ParseTask;
    name_func_map["totem"]          = &ParseTotem;
    name_func_map["totemglyph"]     = &ParseTotemGlyph;
    name_func_map["soldier"]        = &ParseSoldier;
    name_func_map["gut"]            = &ParseGut;
    name_func_map["var"]            = &ParseVar;
    name_func_map["fight"]          = &ParseFight;
    name_func_map["copy"]           = &ParseCopy;
    name_func_map["trial"]          = &ParseTrial;
    name_func_map["tomb"]           = &ParseTomb;
}

} // namespace command

SO_LOAD( command_interface_register )
{
    command::Build();
}
