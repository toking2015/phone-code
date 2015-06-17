#include "guild_imp.h"
#include "user_imp.h"
#include "coin_imp.h"
#include "mail_imp.h"
#include "var_imp.h"
#include "guild_dc.h"
#include "user_dc.h"
#include "event.h"
#include "local.h"
#include "resource/r_globalext.h"
#include "resource/r_guildlevelext.h"
#include "resource/r_guildcontributeext.h"
#include "proto/system.h"
#include "proto/item.h"
#include "proto/constant.h"
#include "proto/broadcast.h"
#include "guild_event.h"
#include "server.h"

namespace guild
{

bool TryLock( SGuild* guild )
{
    uint32 time_now = (uint32)server::local_time();
    if ( guild->data.protect.lock_time >= time_now )
        return false;

    return true;
}

bool Lock( SGuild* guild, uint32 seconds )
{
    uint32 time_now = (uint32)server::local_time();
    if ( guild->data.protect.lock_time >= time_now )
        return false;

    guild->data.protect.lock_time = time_now + seconds;
    return true;
}

void Unlock( SGuild* guild )
{
    guild->data.protect.lock_time = 0;
}

uint32 GetMasterId(SGuild *guild)
{
    return guild->data.simple.creator_id;
}

uint32 Apply(SGuild *guild, SUser *user)
{
    if (user->data.simple.guild_id != 0)
        return kErrGuildExist;
    uint32 apply_limit = theGlobalExt.get<uint32>("apply_guild_max");
    if (user->ext.apply_guilds.size() >= apply_limit)
        return kErrGuildApplyMax;
    apply_limit = theGlobalExt.get<uint32>("apply_user_max");
    if (guild->ext.apply_users.size() >= apply_limit)
        return kErrGuildApplyFull;

    guild->ext.apply_users.push_back(user->guid);
    ApplyNotify(GetMasterId(guild), user->guid, kObjectAdd);
    return 0;
}

void DelAllApply(SUser *user)
{
    for (std::vector<uint32>::iterator iter = user->ext.apply_guilds.begin();
        iter != user->ext.apply_guilds.end();
        ++iter)
    {
        SGuild *guild = theGuildDC.find(*iter);
        if (!guild)
            continue;
        guild->ext.apply_users.erase(std::remove(guild->ext.apply_users.begin(), guild->ext.apply_users.end(), *iter), guild->ext.apply_users.end());
        ApplyNotify(GetMasterId(guild), *iter, kObjectDel);
    }
    user->ext.apply_guilds.clear();
    ReplyApplyGuilds(user);
}

uint32 DelApply(SGuild *guild, uint32 role_id)
{
    guild->ext.apply_users.erase(std::remove(guild->ext.apply_users.begin(), guild->ext.apply_users.end(), role_id), guild->ext.apply_users.end());
    ApplyNotify(GetMasterId(guild), role_id, kObjectDel);
    return 0;
}

void ApplyNotify(uint32 master_id, uint32 role_id, uint32 set_type)
{
    SUser *user = theUserDC.find(master_id);
    if (!user)
        return;
    PRGuildApplySet rep;
    rep.set_type = set_type;
    rep.target_id = role_id;
    bccopy(rep, user->ext);
    local::write(local::access, rep);
}

void ReplyApplyGuilds(SUser *user)
{
    PRGuildApply rep;
    rep.apply_list = user->ext.apply_guilds;
    bccopy(rep, user->ext);
    local::write(local::access, rep);
}

uint32 Approve(SUser *user, SGuild *guild, SUser *target_user, bool is_accpet)
{
    if (target_user->data.simple.guild_id != 0)
        return kErrGuildExist;

    if (user->guid != GetMasterId(guild))
        return kErrGuildAuthority;

    std::vector<uint32>::iterator iter = std::find(guild->ext.apply_users.begin(), guild->ext.apply_users.end(), target_user->guid);
    if (iter == guild->ext.apply_users.end())
        return kErrGuildApplyNotFound;

    CGuildLevelData::SData *p_data = theGuildLevelExt.Find(guild->data.simple.level);
    if (!p_data)
        return kErrGuildData;

    if (p_data->member_count <= guild->data.member_list.size())
        return kErrGuildMemberMax;

    if (is_accpet)
    {
        Join(guild, target_user);

        AddLog(guild, kGuildLogJoin, target_user->data.simple.name);

        std::ostringstream body;
        body << "亲爱的玩家，很高兴地通知您，" << guild->data.simple.name << "的会长已经接受了您的入会申请，您可以进入公会了。";
        mail::send(kMailFlagSystem, target_user->guid, "公会", "申请通过", body.str());
    }
    else
    {
        std::ostringstream body;
        body << "亲爱的玩家，很遗憾地通知您，" << guild->data.simple.name << "的会长已经拒绝了您的入会申请，您可以继续申请其他公会。";
        mail::send(kMailFlagSystem, target_user->guid, "公会", "申请拒绝", body.str());
    }
    DelApply(guild, target_user->guid);
    return 0;
}

uint32 GetJob( SGuild* guild, uint32 role_id )
{
    for ( std::vector< SGuildMember >::iterator iter = guild->data.member_list.begin();
        iter != guild->data.member_list.end();
        ++iter )
    {
        if ( iter->role_id == role_id )
            return iter->job;
    }

    return 0;
}

uint32 Join(SGuild* guild, SUser *user)
{
    //记录角色公会字段
    user->data.simple.guild_id = guild->guid;

    //增加公会成员
    SGuildMember member;
    member.role_id = user->guid;
    member.job = kGuildJobCommon;
    member.join_time = time(NULL);
    guild->data.member_list.push_back( member );

    //加入公会事件
    event::dispatch( SEventGuildJoin( user, guild, kPathGuildJoin ) );

    ReplyMemberSet(guild, member, kObjectAdd);

    return 0;
}

struct guild_member_equal_guid
{
    uint32 guid;
    guild_member_equal_guid( uint32 id ) : guid(id){}

    bool operator()( SGuildMember& data )
    {
        return data.role_id == guid;
    }
};
uint32 Quit(SGuild* guild, SUser* user)
{
    std::vector< SGuildMember >::iterator iter = std::find_if(
        guild->data.member_list.begin(), guild->data.member_list.end(), guild_member_equal_guid( user->guid ) );
    if (iter == guild->data.member_list.end())
        return kErrGuildData;

    uint32 job = iter->job;
    if ( job == kGuildJobMaster )
        return kErrGuildExitMaster;

    //清除公会id标志
    user->data.simple.guild_id = 0;

    ReplyMemberSet(guild, *iter, kObjectDel);

    //移除成员数据
    guild->data.member_list.erase( iter );

    //贡献度减少
    uint32 factor = theGlobalExt.get<uint32>("guild_quit_contribute_i");
    S3UInt32 coin = coin::create(kCoinGuildContribute, 0, 0);
    uint32 value = coin::count(user, coin);
    uint32 left = (uint32)(value * (factor / 10000.0));
    if (value > left)
    {
        S3UInt32 tmp = coin::create(kCoinGuildContribute, 0, value - left);
        coin::take(user, tmp, kPathGuildExit);
    }

    //退出公会事件
    event::dispatch( SEventGuildExit( user, guild, kPathGuildExit, job ) );

    return 0;
}

uint32 ChangeJob( SGuild* guild, SUser* user, SUser* target, uint32 job )
{
    if ( job < kGuildJobCommon || job > kGuildJobMaster )
        return kErrGuildJobChangePurview;

    if ( user->guid == target->guid )
        return kErrGuildJobChangeSelf;

    std::vector< SGuildMember >::iterator self_iter = std::find_if(
        guild->data.member_list.begin(), guild->data.member_list.end(), guild_member_equal_guid( target->guid ) );
    if (self_iter == guild->data.member_list.end())
        return kErrGuildData;

    if ( self_iter->job != kGuildJobMaster )
        return kErrGuildJobChangePurview;

    std::vector< SGuildMember >::iterator iter = std::find_if(
        guild->data.member_list.begin(), guild->data.member_list.end(), guild_member_equal_guid( target->guid ) );
    if ( iter == guild->data.member_list.end() )
        return kErrGuildMemberNoExist;

    int32 old_job = iter->job;

    //修改职务数据
    if (job == kGuildJobMaster)
    {
        self_iter->job = kGuildJobCommon;
        std::ostringstream oss;
        oss << user->data.simple.name << "|" << target->data.simple.name;
        AddLog(guild, kGuildLogMasterChange, oss.str());
        ReplyMemberSet(guild, *self_iter, kObjectUpdate);
    }
    iter->job = job;
    ReplyMemberSet(guild, *iter, kObjectUpdate);

    //权限修改事件
    event::dispatch( SEventGuildJobChange( user, guild, kPathGuildJobChange, target, old_job, iter->job ) );

    return 0;
}

uint32 Kick(SGuild* guild, SUser* user, SUser* target)
{
    uint32 job = GetJob(guild, user->guid);
    if (job != kGuildJobMaster)
        return kErrGuildJobChangePurview;
    if ( user->guid == target->guid )
        return kErrGuildJobChangeSelf;

    std::vector< SGuildMember >::iterator iter = std::find_if(
        guild->data.member_list.begin(), guild->data.member_list.end(), guild_member_equal_guid( target->guid ) );
    if ( iter == guild->data.member_list.end() )
        return kErrGuildMemberNoExist;

    ReplyMemberSet(guild, *iter, kObjectDel);

    //移除成员数据
    guild->data.member_list.erase( iter );

    AddLog(guild, kGuildLogKick, target->data.simple.name);

    tm tm;
    time_t now = time(NULL);
    localtime_r(&now, &tm);
    std::ostringstream body;
    body << "亲爱的玩家，您已于" << tm.tm_mon << "月" << tm.tm_mday << "日被" << guild->data.simple.name << "的会长" << user->data.simple.name << "移出公会，您可以继续申请其他公会。";
    mail::send(kMailFlagSystem, target->guid, "公会", "您已被移出公会", body.str());

    return 0;
}

uint32 Contribute(SGuild *guild, SUser *user, uint32 id)
{
    CGuildContributeData::SData *p_data = theGuildContributeExt.Find(id);
    if (!p_data)
        return kErrGuildData;

    std::vector< SGuildMember >::iterator iter = std::find_if(
        guild->data.member_list.begin(), guild->data.member_list.end(), guild_member_equal_guid( user->guid ) );
    if ( iter == guild->data.member_list.end() )
        return kErrGuildMemberNoExist;

    char buff[32] = { 0 };
    snprintf(buff, sizeof(buff), "guild_contribute_times_%d", id);
    std::string key(buff);
    uint32 id_times = var::get(user, key);
    if (id_times > 0)
        return kErrGuildContributeTimeLimit;

    if (coin::check_take(user, p_data->cost) != 0)
        return kErrCoinLack;

    if (coin::check_give(user, p_data->coins) != 0)
        return kErrItemSpaceFull;

    coin::take(user, p_data->cost, kPathGuildContribute);
    S3UInt32 tmp = coin::create(kCoinGuildContribute, 0, p_data->contribute);
    coin::give(user, tmp, kPathGuildContribute);
    coin::give(user, p_data->coins, kPathGuildContribute);

    iter->daily_contribute += p_data->contribute;
    iter->history_contribute += p_data->contribute;
    ReplyMemberSet(guild, *iter, kObjectUpdate);

    uint32 xp = p_data->contribute / 10;
    AddXp(guild, user, xp, kPathGuildContribute);

    std::vector<std::string> params;
    std::ostringstream oss;
    oss << user->data.simple.name << "|" << p_data->name << "|" << p_data->contribute << "|" << xp;
    AddLog(guild, kGuildLogContribute, oss.str());

    var::set(user, key, id_times + 1);
    return 0;
}

uint32 Levelup(SGuild *guild, SUser *user)
{
    if (user->guid != GetMasterId(guild))
        return kErrGuildAuthority;
    CGuildLevelData::SData *p_data = theGuildLevelExt.Find(guild->data.simple.level);
    if (!p_data)
        return kErrGuildData;
    if (p_data->levelup_xp < guild->data.info.xp)
        return kErrGuildLevelupXpLack;

    guild->data.simple.level++;
    DelXp(guild, user, p_data->levelup_xp, kPathGuildLevelup);
    ReplyLevel(guild);

    AddLog(guild, kGuildLogLevelup, user->data.simple.name);

    return 0;
}

void AddXp(SGuild *guild, SUser *user, uint32 value, uint32 path)
{
    guild->data.info.xp += value;
    event::dispatch(SEventGuildXp( user, guild, path, value, kObjectAdd ) );
}

void DelXp(SGuild *guild, SUser *user, uint32 value, uint32 path)
{
    if (guild->data.info.xp > value)
        guild->data.info.xp -= value;
    else
        guild->data.info.xp = 0;
    event::dispatch(SEventGuildXp( user, guild, path, value, kObjectDel ));
}

void AddLog(SGuild *guild, uint32 log_type, std::string params)
{
    SGuildLog log;
    log.type = log_type;
    log.time = time(NULL);
    log.params = params;
    guild->data.log_list.push_back(log);
}

void ReplyMemberSet(SGuild *guild, SGuildMember &member, uint32 set_type)
{
    PRGuildMemberSet rep;
    rep.broad_cast = kCastGuild;
    rep.broad_id = guild->data.simple.guid;
    rep.set_type = set_type;
    rep.member = member;
    local::write(local::access, rep);
}

void ReplyLevel(SGuild *guild)
{
    PRGuildLevel rep;
    rep.broad_cast = kCastGuild;
    rep.broad_id = guild->data.simple.guid;
    rep.xp = guild->data.info.xp;
    rep.level = guild->data.simple.level;
    local::write(local::access, rep);
}

} // namespace guild
