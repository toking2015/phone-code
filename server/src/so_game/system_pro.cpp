#include "misc.h"
#include "proto/system.h"
#include "msg.h"
#include "user_dc.h"
#include "guild_dc.h"
#include "system_dc.h"
#include "event.h"
#include "local.h"
#include "raw.h"
#include "var_imp.h"
#include "user_event.h"
#include "guild_event.h"
#include "user_imp.h"
#include "server.h"
#include "system_imp.h"

MSG_FUNC( PQSystemTest )
{
    char* p = NULL;
    *p = 'a';
}

MSG_FUNC( PQSystemOnline )
{
    QU_ON( user, msg.role_id );

    user->ext.operate_time = server::local_time();

    local::write( local::auth, msg );
}

MSG_FUNC( PQSystemSessionCheck )
{
    QU_ON( user, msg.role_id );

    PRSystemSessionCheck rep;
    bccopy( rep, user->ext );

    local::write( local::access, rep );
}

MSG_FUNC( PQSystemAuth )
{
    if ( key != local::auth )
        return;

    PRSystemAuth rep;
    rep.role_id = msg.role_id;
    rep.outside_sock = msg.outside_sock;

    rep.session = theSystemDC.create( msg.role_id );

    local::write( local::auth, rep );
}

MSG_FUNC( PQSystemLogin )
{
    if ( msg.role_id == 0 )
        return;

    uint32 session = theSystemDC.get_session( msg.role_id );
    if ( session == 0 || msg.session != session )
        return;

    std::map< uint32, SUser >::iterator iter = theUserDC.db().user_map.find( msg.role_id );
    if ( iter == theUserDC.db().user_map.end() )
    {
        //如果角色不存在, 即创建用户
        theUserDC.query_load( msg.role_id, true );

        //延迟协议处理
        wd::CStream* stream = new wd::CStream();
        *stream << msg;
        theUserDC.defer_msg( msg.role_id, sock, key, stream );
        return;
    }
    SUser* user = &(iter->second);

    user->ext.session = session;
    user->ext.role_id = user->guid;

    user->ext.operate_time = server::local_time();

    //处理用户登入前处理
    event::dispatch( SEventUserLogin( user, kPathUserLogin ) );

    //返回登录成功协议包
    {
        PRSystemLogin rep;
        bccopy( rep, user->ext );

        struct  timeval    tv;
        struct  timezone   tz;
        gettimeofday(&tv,&tz);
        rep.open_time   = server::get<uint32>("open_time");
        rep.server_time = tv.tv_sec;
        rep.minuteswest = tz.tz_minuteswest;
        rep.dsttime = tz.tz_dsttime;
        rep.outside_sock = msg.outside_sock;

        local::write( local::access, rep );
    }

    //返回用户数据协议包
    user::reply_data( user );

    //处理用户登入后事件
    event::dispatch( SEventUserLogined( user, kPathUserLogin ) );
}

MSG_FUNC( PRSystemUserLoad )
{
    if ( msg.guid == 0 )
    {
        LOG_ERROR( "PRSystemUserLoad.guid must not be 0!" );
        return;
    }

    //现登录用户容错处理
    SUser* user = theUserDC.find( msg.guid );
    if ( user != NULL )
        return;

    //创建用户数据
    user = theUserDC.create( msg.guid, msg.data );

    //尝试读取备份数据模块
    if ( user->data.simple.team_level <= 1 )
    {
        if ( theUserDC.load_file( msg.guid, user->data ) )
        {
            msg.created = 0;

            LOG_ERROR( "load file: %u - %u", msg.guid, user->data.simple.team_level );
        }
    }

    //初始化用户md5校验数据
    raw::init_md5( user->data, user->ext.check );

    //处理新用户登入事件
    if ( msg.created )
        event::dispatch( SEventUserInit( user, kPathUserInit ) );

    //处理用户加载事件
    event::dispatch( SEventUserLoaded( user, kPathUserLoad ) );

    //处理正在等待用户数据的协议(发送到处理列表)
    theUserDC.dispatch_defer( msg.guid );
}

MSG_FUNC( PRSystemGuildLoad )
{
    //现登录用户容错处理
    SGuild* guild = theGuildDC.find( msg.guid );
    if ( guild != NULL )
        return;

    //创建用户数据
    guild = theGuildDC.create( msg.guid, msg.data );

    //初始化用户md5校验数据
    raw::init_md5( guild->data, guild->ext.check );

    //处理新用户登入事件
    if ( guild->data.simple.name.empty() )
        event::dispatch( SEventGuildInit( guild, kPathGuildInit ) );

    //处理用户登入事件
    event::dispatch( SEventGuildLoaded( guild, kPathGuildLoad ) );

    //处理正在等待用户数据的协议(发送到处理列表)
    theGuildDC.dispatch_defer( msg.guid );
}

MSG_FUNC( PQSystemKick )
{
    if ( key != local::auth )
        return;

    if ( msg.role_id == 0 )
        return;

    QU_ON( user, msg.role_id );

    PRSystemKick rep;
    bccopy( rep, user->ext );

    local::write( local::access, rep );
}

MSG_FUNC( PQSystemPlacard )
{
    if ( key != local::auth )
        return;

    sys::placard( msg.order, msg.flag, msg.text, msg.broad_cast, msg.broad_type, msg.broad_id );
}

