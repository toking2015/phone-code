#ifndef _IMMORTAL_AUTH_CALL_PRO_H_
#define _IMMORTAL_AUTH_CALL_PRO_H_

#include "call_imp.h"
#include "log.h"

#define JSON_FUNC( n )\
struct _json_call_dec_##n\
{\
    static void call( std::string cmd, int32 sock, CJson& json );\
    _json_call_dec_##n()\
    {\
        json::AddCall( #n, _json_call_dec_##n::call );\
    }\
}_json_call_var_##n;\
void _json_call_dec_##n::call( std::string cmd, int32 sock, CJson& json )

#define JSON_PARAM_CHECK( ele )\
    if ( json[ #ele ].type() == Json::nullValue )\
    {\
        LOG_ERROR( "json param [%s.%s] not found!", cmd.c_str(), #ele );\
        return;\
    }

#endif // #define _IMMORTAL_AUTH_CALL_PRO_H_

