#ifndef _IMMORTAL_AUTHSVR_CALL_IMP_H_
#define _IMMORTAL_AUTHSVR_CALL_IMP_H_

#include "common.h"
#include "jsonconfig.h"

namespace json
{
    typedef void (*JsonHandler)( std::string cmd, int32 sock, CJson& json );

    void AddCall( std::string name, JsonHandler handler );
    std::pair< int32, std::string > Process( int32 sock, std::string& json_string, uint32 runtime_guid = 0 );
    void RunCall( int32 sock, std::string& json_string );

    void Terminate( uint32 runtime_guid );
};
#define theJsonCall TSignleton< CJsonCall >::Ref()

#endif

