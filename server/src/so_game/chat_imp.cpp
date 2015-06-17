#include "chat_imp.h"
#include "server.h"

namespace chat
{

//< time, < rid, < index, sound > > >
std::map< uint32, std::map< uint32, std::map< uint32, wd::CStream > > > sound_data;
const uint32 sound_valid_sec = 300;     //5分钟有效期

void cache_sound( uint32 rid, uint32 index, wd::CStream& bytes )
{
    uint32 time_limit = server::local_time() / sound_valid_sec;

    sound_data[ time_limit ][ rid ][ index ] = bytes;
}

wd::CStream* find_sound( uint32 rid, uint32 index )
{
    for ( std::map< uint32, std::map< uint32, std::map< uint32, wd::CStream > > >::iterator i = sound_data.begin();
        i != sound_data.end();
        ++i )
    {
        std::map< uint32, std::map< uint32, wd::CStream > >::iterator j = i->second.find( rid );
        if ( j == i->second.end() )
            continue;

        std::map< uint32, wd::CStream >::iterator k = j->second.find( index );
        if ( k == j->second.end() )
            continue;

        return &( k->second );
    }

    return NULL;
}

void clear_timeout_sound(void)
{
    uint32 time_limit = ( server::local_time() / sound_valid_sec ) - 1;

    std::vector< uint32 > remove_list;
    for ( std::map< uint32, std::map< uint32, std::map< uint32, wd::CStream > > >::iterator i = sound_data.begin();
        i != sound_data.end();
        ++i )
    {
        if ( i->first < time_limit )
            remove_list.push_back( i->first );
    }

    for ( std::vector< uint32 >::iterator i = remove_list.begin();
        i != remove_list.end();
        ++i )
    {
        sound_data.erase( *i );
    }
}

}// namespace chat
