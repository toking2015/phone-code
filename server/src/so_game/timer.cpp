#include "timer.h"
#include "timer_event.h"

void OnTimerListen( std::string& key, uint32 msec )
{
    event::dispatch( SEventTimerOnTime( key, msec ) );
}
SO_LOAD( timer_reg )
{
    timer::set_listen_call( OnTimerListen );
}

