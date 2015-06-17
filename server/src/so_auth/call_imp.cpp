#include "call_imp.h"

#include "misc.h"
#include "util.h"
#include "netio.h"
#include "local.h"
#include "log.h"

#include "proto/constant.h"
#include "proto/auth.h"
#include "auth_dc.h"
#include "sockcoolmgr.h"
#include "systimemgr.h"

namespace json
{

std::map< std::string, JsonHandler >& handler_map(void)
{
    static std::map< std::string, JsonHandler > map;

    return map;
}

void AddCall( std::string name, JsonHandler handler )
{
    handler_map()[ name ] = handler;
}

struct outside_run_time
{
    std::string json_string;
    uint32 guid;
    outside_run_time( std::string& str, uint32 g ) : json_string(str), guid(g){}

    void operator()(void)
    {
        std::map< uint32, SAuthRunData >::iterator iter = theAuthDC.db().loop_map.find( guid );
        if ( !theSysTimeMgr.Valid( iter->second.loop_id ) )
        {
            theAuthDC.db().loop_map.erase( iter );

            PQAuthRunTimeSet req;

            req.set_type = kObjectDel;
            req.run_time.guid = guid;

            local::write( local::realdb, req );
        }

        json::RunCall( 0, json_string );
    }
};
std::pair< int32, std::string > Process( int32 sock, std::string& json_string, uint32 runtime_guid/* = 0*/ )
{
    CJson json;

    std::string cmd;

    if ( !json.read( json_string.c_str(), CJson::kString ) )
    {
        LOG_ERROR( "json read error: %s", json_string.c_str() );
        return std::make_pair( (int32)kAuthRunJsonFlagError, "" );
    }

    if ( json[ "cmd" ].type() != Json::stringValue )
    {
        LOG_ERROR( "json cmd error: %s", json_string.c_str() );
        return std::make_pair( (int32)kAuthRunJsonFlagError, "" );
    }

    cmd = to_str( json[ "cmd" ] );

    std::map< std::string, JsonHandler >::iterator iter = handler_map().find( cmd );
    if ( handler_map().end() == iter )
    {
        LOG_ERROR( "json handler not found: %s", json_string.c_str() );
        return std::make_pair( (int32)kAuthRunJsonFlagError, cmd );
    }

    if ( cmd != "sys_auth" && cmd != "sys_pay" )
        LOG_INFO( "json run: %s", json_string.c_str() );

    std::string run_time;
    if ( json[ "run_time" ].type() == Json::stringValue )
        run_time = to_str( json[ "run_time" ] );

    json[ "runtime_guid" ] = runtime_guid;

    if ( !run_time.empty() )
    {
        uint32 run_count = 0;
        uint32 run_type = 0;
        uint32 run_delay = 0;

        if ( json[ "run_type" ].type() != Json::nullValue )
            run_type = to_uint( json[ "run_type" ] );
        if ( json[ "run_delay" ].type() != Json::nullValue )
            run_delay = to_uint( json[ "run_delay" ] );
        if ( json[ "run_count" ].type() != Json::nullValue )
            run_count = to_uint( json["run_count"] );

        if ( run_type == 0 )
        {
            //定时执行
            struct tm t_tm = {0};

            //以本地时区( 带夏令时 )初始化 t_tm 结构
            time_t time_now = time(NULL);
            localtime_r( &time_now, &t_tm );

            //修改 t_tm 结构为 run_time 时间
            strptime( run_time.c_str(), "%Y-%m-%d %H:%M:%S", &t_tm );

            //获取秒数
            time_t time_run = mktime( &t_tm );

            if ( time_run > time_now )
            {
                if ( runtime_guid != 0 )
                {
                    SAuthRunData& data = theAuthDC.db().loop_map[ runtime_guid ];

                    data.guid = runtime_guid;
                    data.json_string = json_string;

                    data.loop_id = theSysTimeMgr.AddCall(
                        "#auth_outside_run_time",
                        Json::FastWriter().write( json.value() ),
                        (uint32)( time_run - time_now + 1 ) );
                }

                return std::make_pair( (int32)kAuthRunJsonFlagDefer, cmd );
            }
        }
        else
        {
            //循环执行
            if ( runtime_guid != 0 )
            {
                uint32 run_id = theSysTimeMgr.AddLoop
                (
                    "#auth_outside_run_time",
                    Json::FastWriter().write( json.value() ),
                    run_time.c_str(),
                    NULL,
                    run_type,
                    run_delay,
                    run_count
                );

                if ( run_id <= 0 )
                {
                    PQAuthRunTimeSet req;

                    req.set_type = kObjectDel;
                    req.run_time.guid = runtime_guid;

                    local::write( local::realdb, req );

                    return std::make_pair( (int32)kAuthRunJsonFlagSucceed, cmd );
                }
                else
                {
                    SAuthRunData& data = theAuthDC.db().loop_map[ runtime_guid ];

                    data.guid = runtime_guid;
                    data.json_string = json_string;
                    data.loop_id = run_id;
                }
            }

            return std::make_pair( (int32)kAuthRunJsonFlagLoop, cmd );
        }
    }

    iter->second( cmd, sock, json );

    return std::make_pair( (int32)kAuthRunJsonFlagSucceed, cmd );
}

void RunCall( int32 sock, std::string& json_string )
{
    CJson json;

    if ( !json.read( json_string.c_str(), CJson::kString ) )
    {
        LOG_ERROR( "json read error: %s", json_string.c_str() );
        return;
    }

    if ( json[ "cmd" ].type() != Json::stringValue )
    {
        LOG_ERROR( "json cmd error: %s", json_string.c_str() );
        return;
    }

    std::string cmd = to_str( json[ "cmd" ] );

    std::map< std::string, JsonHandler >::iterator iter = handler_map().find( cmd );
    if ( handler_map().end() == iter )
    {
        LOG_ERROR( "json handler not found: %s", json_string.c_str() );
        return;
    }

    iter->second( cmd, sock, json );
}

void Terminate( uint32 runtime_guid )
{
    std::map< uint32, SAuthRunData >::iterator iter = theAuthDC.db().loop_map.find( runtime_guid );
    if ( iter == theAuthDC.db().loop_map.end() )
        return;

    theSysTimeMgr.RemoveLoop( iter->second.loop_id );

    PQAuthRunTimeSet req;

    req.set_type = kObjectDel;
    req.run_time.guid = runtime_guid;

    local::write( local::realdb, req );

    theAuthDC.db().loop_map.erase( iter );
}

} // namespace json

