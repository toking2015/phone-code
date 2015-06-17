#ifndef _IMMORTAL_COMMON_PARAM_MGR_H_
#define _IMMORTAL_COMMON_PARAM_MGR_H_

#include "common.h"

struct SParam
{
    uint32 ext_count;
    void(*proc)( std::vector< std::string > );
};

class CParamMgr
{
private:
    std::map< std::string, SParam > param_map;

public:
    void bind( const char* key, uint32 ext_count, void(*proc)( std::vector< std::string > ) );
    bool run( int argc, char** argv, std::string& error );
};
#define theParamMgr TSignleton< CParamMgr >::Ref()

#endif

