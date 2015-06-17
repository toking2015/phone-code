#ifndef _PUBLIC_TIMER_H_
#define _PUBLIC_TIMER_H_

#include "common.h"
#include "misc.h"
#include "systimemgr.h"

class timer
{
public:
    typedef void(*FListenCall)(std::string&, uint32);

public:
    static void bind_handle( std::string name, void(*call)(uint32, std::string&, uint32) );
    static std::map< std::string, void(*)(uint32, std::string&, uint32) >& timer_handle(void);
    static void set_listen_call( FListenCall call );
};

#define TIMER(n)\
    void _timer_##n( uint32 loop_id, std::string& param, uint32 time_sec );\
    SO_LOAD( _timer_reg_##n )\
    {\
        timer::bind_handle( #n, _timer_##n );\
    }\
    void _timer_##n( uint32 loop_id, std::string& param, uint32 time_sec )

#endif

