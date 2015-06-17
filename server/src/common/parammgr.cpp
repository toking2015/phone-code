#include "parammgr.h"

void CParamMgr::bind( const char* key, uint32 ext_count, void(*proc)( std::vector< std::string > ) )
{
    SParam param = { ext_count, proc };
    param_map[ key ] = param;
}

bool CParamMgr::run( int argc, char** argv, std::string& error )
{
    char buff[512];
    for ( int i=0; i<argc; ++i )
    {
        const char* key = argv[i];

        std::map< std::string, SParam >::iterator iter = param_map.find( key );
        if ( iter == param_map.end() )
            continue;

        if ( argc - i - 1 < (int32)iter->second.ext_count )
        {
            snprintf( buff, sizeof( buff ) - 1, "param[%s] param count not enought", key );
            error = buff;
            return false;
        }

        std::vector< std::string > params;
        for ( uint32 j=0; j < iter->second.ext_count; ++j )
            params.push_back( argv[++i] );

        iter->second.proc( params );
    }

    return true;
}

