#include "timer.h"
#include "proto/timer.h"

void timer::bind_handle( std::string name, void(*call)(uint32, std::string&, uint32) )
{
    timer_handle()[ name ] = call;
}

std::map< std::string, void(*)(uint32, std::string&, uint32) >& timer::timer_handle(void)
{
    static std::map< std::string, void(*)(uint32, std::string&, uint32) > handle;

    return handle;
}

timer::FListenCall& timer_listen_call(void)
{
    static timer::FListenCall call = NULL;

    return call;
}

void timer::set_listen_call( timer::FListenCall call )
{
    timer_listen_call() = call;
}

MSG_FUNC( PQTimerEvent )
{
    if ( msg.time_key.empty() )
        return;

    std::string time_key = msg.time_key;
    if ( time_key[0] == '#' )
        time_key.erase( time_key.begin() );

    std::map< std::string, void(*)(uint32, std::string&, uint32) >::iterator iter = timer::timer_handle().find( time_key );
    if ( iter == timer::timer_handle().end() )
        return;

    iter->second( msg.time_id, msg.time_param, msg.time_sec );

    if ( timer_listen_call() != NULL )
        timer_listen_call()( time_key, msg.time_sec );
}

