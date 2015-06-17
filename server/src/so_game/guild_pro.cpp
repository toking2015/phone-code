#include "pro.h"
#include "guild_imp.h"
#include "coin_imp.h"
#include "misc.h"
#include "local.h"
#include "resource/r_globalext.h"
#include "proto/constant.h"
#include "proto/guild.h"
#include "proto/system.h"
#include "proto/coin.h"
#include "proto/broadcast.h"
#include "user_dc.h"
#include "user_imp.h"
#include "guild_dc.h"
#include "server.h"

MSG_FUNC( PQGuildSimple )
{
    SGuildSimple* simple = theGuildDC.find_simple( msg.target_id );
    if ( simple == NULL )
        return;

    PRGuildSimple rep;
    bccopy( rep, msg );

    rep.data = *simple;

    local::write( key, rep );
}

MSG_FUNC( PQGuildPanel )
{
    QG( guild, msg.target_id );

    PRGuildPanel rep;
    bccopy( rep, msg );

    rep.data.simple = guild->data.simple;
    rep.data.info   = guild->data.info;

    local::write( key, rep );
}

MSG_FUNC( PQGuildMemberList )
{
    QG( guild, msg.target_id );

    PRGuildMemberList rep;
    bccopy( rep, msg );

    rep.list = guild->data.member_list;

    local::write( key, rep );
}

MSG_FUNC( PQGuildList )
{
    PRGuildList rep;
    bccopy( rep, msg );

    rep.index = msg.index;
    rep.sum = theGuildDC.query_list( msg.index, msg.count, rep.list );

    local::write( key, rep );
}

MSG_FUNC( PRGuildSimpleList )
{
    if ( msg.list.empty() )
    {
        //当所有数据发送完毕时对所有军团索引进行排序
        theGuildDC.sort();
        return;
    }

    for ( std::vector< SGuildSimple >::iterator iter = msg.list.begin();
        iter != msg.list.end();
        ++iter )
    {
        theGuildDC.db().simple_map[ iter->guid ] = *iter;
    }
}

MSG_FUNC( PQGuildCreate )
{
    QU_ON( user, msg.role_id );

    //已存在公会检查
    if ( user->data.simple.guild_id != 0 )
    {
        HandleErrCode( user, kErrGuildExist, 0 );
        return;
    }

    //空名称检查
    if ( msg.name.empty() )
    {
        HandleErrCode( user, kErrGuildNameEmpty, 0 );
        return;
    }

    //名称特殊字符检查
    //HandleErrCode( user, kErrGuildNameSpecial, 0 );

    //公会名重名检查
    if ( theGuildDC.db().guild_name_id.find( msg.name ) != theGuildDC.db().guild_name_id.end() )
    {
        HandleErrCode( user, kErrGuildNameExist, 0 );
        return;
    }

    //检查用户需要扣除的资源是否满足创建条件( 本条件判断必须要用户复复申请检查之前 )
    S3UInt32 cost = theGlobalExt.get<S3UInt32>("guild_create_cost");
    if (coin::check_take(user, cost) != 0)
    {
        HandleErrCode(user, kErrCoinLack, cost.cate);
        return;
    }

    //锁定用户繁感操作
    if ( !user::Lock( user ) )
    {
        HandleErrCode( user, kErrSystemBusy, 0 );
        return;
    }

    //扣除用户物品
    coin::take(user, cost, kPathGuildCreate);

    //临时注册公会名
    theGuildDC.db().guild_name_id[ msg.name ] = 0;

    //发送到realdb
    local::write( local::realdb, msg );
}

MSG_FUNC( PRGuildCreate )
{
    QU_OFF( user, msg.role_id );

    //解锁用户繁感操作
    user::Unlock( user );

    user->data.simple.guild_id = msg.guild_id;

    //创建公会结构
    SGuildData data;
    data.simple.guid = msg.guild_id;
    data.simple.name = msg.name;
    data.simple.creator_id = msg.role_id;
    data.simple.level = 1;
    data.info.create_time = msg.create_time;
    SGuildMember mem;
    mem.role_id = msg.role_id;
    mem.job = kGuildJobMaster;
    mem.join_time = msg.create_time;
    data.member_list.push_back(mem);
    theGuildDC.create(msg.guild_id, data);

    //映射名称与id
    theGuildDC.db().guild_name_id[ msg.name ] = msg.guild_id;
    theGuildDC.db().guild_id_name[ msg.guild_id ] = msg.name;
    theGuildDC.db().order_member_count.push_back(msg.guild_id);

    local::write( local::access, msg );
}

MSG_FUNC(PQGuildApply)
{
    QU_ON(user, msg.role_id);
    QG(guild, msg.guild_id);
    if (msg.set_type == kObjectAdd)
    {
        int32 err = guild::Apply(guild, user);
        if (err > 0)
            HandleErrCode(user, err, 0);
    }
    else
    {
        guild::DelApply(guild, msg.role_id);
        user->ext.apply_guilds.erase(std::remove(user->ext.apply_guilds.begin(), user->ext.apply_guilds.end(), msg.guild_id), user->ext.apply_guilds.end());
        guild::ReplyApplyGuilds(user);
    }
}

MSG_FUNC(PQGuildApprove)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    QU_OFF(target_user, msg.target_id);
    uint32 err = guild::Approve(user, guild, target_user, msg.is_accept);
    if (err != 0)
        HandleErrCode(user, err, 0);
}

MSG_FUNC(PQGuildQuit)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    uint32 err = guild::Quit(guild, user);
    if (err != 0)
        HandleErrCode(user, err, 0);
}

MSG_FUNC(PQGuildSetJob)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    QU_OFF(target, msg.target_id);
    uint32 err = guild::ChangeJob(guild, user, target, msg.job);
    if (err != 0)
        HandleErrCode(user, err, 0);
}

MSG_FUNC(PQGuildKick)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    QU_OFF(target, msg.target_id);
    uint32 err = guild::Kick(guild, user, target);
    if (err != 0)
        HandleErrCode(user, err, 0);
}

MSG_FUNC(PQGuildContribute)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    uint32 err = guild::Contribute(guild, user, msg.id);
    if (err != 0)
        HandleErrCode(user, err, 0);
}

MSG_FUNC(PQGuildLevelup)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    uint32 err = guild::Levelup(guild, user);
    if (err != 0)
        HandleErrCode(user, err, 0);
}

MSG_FUNC(PQGuildPost)
{
    QU_ON(user, msg.role_id);
    QG(guild, user->data.simple.guild_id);
    if (guild::GetMasterId(guild) != user->data.simple.guild_id)
    {
        HandleErrCode(user, kErrGuildAuthority, 0);
        return;
    }

    if (msg.content.size() > 140)
        return;
    guild->data.info.post_msg = msg.content;
    PRGuildPost rep;
    rep.broad_cast = kCastGuild;
    rep.broad_id = guild->data.simple.guid;
    rep.content = msg.content;
    bccopy(rep, msg);
    local::write(local::access, rep);
}
