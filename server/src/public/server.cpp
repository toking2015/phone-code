#include "server.h"
#include "server_dc.h"
#include "local.h"
#include "settings.h"

namespace server
{

uint32 local_time( uint32 time /* = 0 */ )
{
    if ( global_debug_time != 0 )
        return global_debug_time;

    static uint32 __time = (uint32)::time(NULL);
    if ( time != 0 )
        __time = time;

    return __time;
}

uint32 local_6_time( uint32 time, int32 day/* = 0 */ )
{
    if ( time == 0 )
        time = local_time();

    struct tm __tm = {0};

    time_t _t_time = time;
    localtime_r( &_t_time, &__tm );

    bool less_6 = false;
    if ( __tm.tm_hour < 6 )
        less_6 = true;

    __tm.tm_hour = 6;
    __tm.tm_min = 0;
    __tm.tm_sec = 0;

    uint32 seconds = (uint32)( mktime( &__tm ) + day * 86400 );
    if ( less_6 )
        seconds -= 86400;

    return seconds;
}

uint32 get_local_sub_day( uint32 time )
{
    if ( 0 == time )
        return 0;

    time_t _time = time;
    time_t time_now = local_time();

    if ( time > time_now )
        return 0;

    uint32 _time1 = local_6_time( _time );
    uint32 _time2 = local_6_time( local_time() );

    return _time2 / 86400 - _time1 / 86400;
}

std::map< std::string, std::string >& data_map(void)
{
    return theServerDC.db().key_value;
}

std::list< int32 >& id_list(void)
{
    static std::list< int32 > list;

    if ( list.empty() )
    {
        const Json::Value aj = settings::json()[ "sql" ];

        for ( uint32 i = 0; i < aj.size(); ++i )
        {
            const char* name = aj[i]["name"].asCString();
            int32 sid = 0;

            if ( 0 != sscanf( name, "%d", &sid ) )
            {
                if ( sid != 0 )
                    list.push_back( sid );
            }
        }
    }

    return list;
}

void broadcast_modifity( std::string key, std::string value )
{
    PQServerNotify msg;

    msg.key = key;
    msg.value = value;

    local::broadcast( msg );
}

//get
template<>
std::string get<std::string>( std::string name )
{
    std::map< std::string, std::string >::iterator iter = data_map().find( name );
    if ( iter == data_map().end() )
        return std::string();

    return iter->second;
}

template<>
int8 get<int8>( std::string name )
{
    return (int8)get< int32 >( name );
}

template<>
uint8 get<uint8>( std::string name )
{
    return (uint32)get< uint32 >( name );
}

//set
template<>
void set<int8>( std::string key, int8 value )
{
    set<int32>( key, (int32)value );
}
template<> void set<uint8>( std::string key, uint8 value )
{
    set<uint32>( key, (uint32)value );
}

}// namespace server
