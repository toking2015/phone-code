#include "proto/transfrom/transfrom_timer.h"

#include "proto/timer/PQTimerEvent.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_timer::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 113037829 ] = std::make_pair( "PQTimerEvent", msg_transfrom< PQTimerEvent > );

    return handles;
}

