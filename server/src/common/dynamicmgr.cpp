#include "dynamicmgr.h"
#include "log.h"
#include "misc.h"

CDynamicMgr::CDynamicMgr()
{
    so_index = 0;

    OnLoaded = NULL;
    OnUnload = NULL;
}

void CDynamicMgr::config_local_dir( std::string dir )
{
    local_dir = dir;
}

void CDynamicMgr::config_so_name( std::string name, std::string file )
{
    handle_map[ name ].first = file;
}

void CDynamicMgr::load( std::string name )
{
    std::map< std::string, std::pair< std::string, void* > >::iterator iter = handle_map.find( name );
    if ( iter == handle_map.end() )
    {
        LOG_ERROR( "dynamic [%s] not found!", name.c_str() );
        return;
    }

    if ( iter->second.second != NULL )
    {
        if ( OnUnload != NULL )
            OnUnload();

        dlclose( iter->second.second );
    }

    std::string load_name = iter->second.first;
    /*
    if ( ++so_index > 1 )
    {
        int32 idx1 = iter->second.first.find_last_of( '/' );
        int32 idx2 = iter->second.first.find_last_of( '.' );

        std::string path_name = iter->second.first.substr( 0, idx1 );
        std::string first_name = iter->second.first.substr( idx1 + 1, idx2 - idx1 - 1 );
        std::string last_name = iter->second.first.substr( idx2 + 1 );

        load_name = strprintf( "%s/%s_%d.%s", local_dir.c_str(), first_name.c_str(), so_index, last_name.c_str() );
        local_execute( "rm -f %s", load_name.c_str() );
        local_execute( "cp %s %s", iter->second.first.c_str(), load_name.c_str() );
    }
    */

    iter->second.second = dlopen( load_name.c_str(), RTLD_NOW );
    if ( iter->second.second == NULL )
    {
        char* error_string = dlerror();
        LOG_ERROR( "dynamic load failure: %s", error_string );
        exit(0);
        return;
    }

    if ( OnLoaded != NULL )
        OnLoaded();
}

void CDynamicMgr::close( std::string name )
{
    std::map< std::string, std::pair< std::string, void* > >::iterator iter = handle_map.find( name );
    if ( iter == handle_map.end() )
        THROW( "dynamic [%s] not found!", name.c_str() );

    if ( iter->second.second != NULL )
    {
        dlclose( iter->second.second );
        iter->second.second = NULL;
    }
}

void CDynamicMgr::func_reg( std::string name, void** var )
{
    if ( call_map.find( name ) != call_map.end() )
        return;

    call_map[ name ] = var;
}

void CDynamicMgr::func_set( std::string name, void* call )
{
    std::map< std::string, void** >::iterator iter = call_map.find( name );
    if ( iter == call_map.end() )
        return;

    *(iter->second) = call;
}

