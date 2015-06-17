#include "sockcoolmgr.h"
#include "settings.h"

#include "log.h"

void CSockCoolMgr::release( int32 sock )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    sock_release_map[ sock ] = time(NULL) + settings::json()[ "sock_cooling_time" ].asInt();
}

bool CSockCoolMgr::InCooling( int32 sock )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    return sock_release_map.find( sock ) != sock_release_map.end();
}

void CSockCoolMgr::process(void)
{
    wd::CGuard<wd::CMutex> safe( &mutex );
    {
        uint32 time_now = (uint32)time(NULL);
        std::list< int32 > sock_list;
        for ( std::map< int32, uint32 >::iterator iter = sock_release_map.begin();
            iter != sock_release_map.end();
            ++iter )
        {
            if ( time_now > iter->second )
                sock_list.push_back( iter->first );
        }

        for ( std::list< int32 >::iterator iter = sock_list.begin();
            iter != sock_list.end();
            ++iter )
        {
            int32 sock = *iter;

            sock_release_map.erase( sock );
            close( sock );
        }

        if ( sock_release_map.size() > 1024 )
            LOG_ERROR( "WARN_COOL: size[%lu] > 1024", sock_release_map.size() );
    }
}

