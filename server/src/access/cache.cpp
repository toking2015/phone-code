#include "cache.h"
#include "user.h"
#include "pack.h"
#include "systimemgr.h"
#include "netio.h"

namespace cache
{

std::map< uint32, std::set< uint64 > >& user_set(void)
{
    static std::map< uint32, std::set< uint64 > > map;

    return map;
}

std::map< uint64, SChannel* >& channel_map(void)
{
    static std::map< uint64, SChannel* > map;

    return map;
}

uint64 channel_to_value( uint16 cast, uint16 type, uint32 id )
{
    return ( (uint64)cast << 48 ) | ( (uint64)type << 32 ) | ( (uint64)id );
}
SChannel::SData value_to_channel( uint64 value )
{
    SChannel::SData channel;

    channel.cast = ( value >> 48 ) & 0xFFFF;
    channel.type = ( value >> 32 ) & 0xFFFF;
    channel.id = value & 0xFFFFFFFF;

    return channel;
}

SChannel* query_channel( uint64 value )
{
    SChannel* channel = NULL;

    std::map< uint64, SChannel* >::iterator iter = channel_map().find( value );
    if ( iter == channel_map().end() )
        channel_map().insert( std::make_pair( value, ( channel = new SChannel ) ) );
    else
        channel = iter->second;

    return channel;
}

void push( uint64 value, wd::CStream& stream )
{
    SChannel* channel = query_channel( value );

    if ( channel->stream.length() <= 0 )
        channel->stream.resize( sizeof( tag_pack_head ) );

    channel->stream << stream;
}

std::vector< uint64 > query_channel_list( uint32 role_id )
{
    std::vector< uint64 > list;

    std::map< uint32, std::set< uint64 > >::iterator iter = user_set().find( role_id );

    for ( std::set< uint64 >::iterator i = iter->second.begin();
        i != iter->second.end();
        ++i )
    {
        list.push_back( *i );
    }

    return list;
}

void set( uint32 role_id, uint64 value )
{
    SChannel* channel = query_channel( value );

    std::set< uint32 >::iterator iter = channel->user_set.find( role_id );
    if ( iter == channel->user_set.end() )
    {
        channel->user_set.insert( role_id );
        user_set()[ role_id ].insert( value );
    }
}

void unset( uint32 role_id, uint64 value )
{
    SChannel* channel = query_channel( value );

    std::set< uint32 >::iterator iter = channel->user_set.find( role_id );
    if ( iter != channel->user_set.end() )
    {
        channel->user_set.erase( iter );
        user_set()[ role_id ].erase( value );
    }
}

void offline( uint32 role_id )
{
    std::map< uint32, std::set< uint64 > >::iterator iter = user_set().find( role_id );
    if ( iter == user_set().end() )
        return;

    for ( std::set< uint64 >::iterator i = iter->second.begin();
        i != iter->second.end();
        ++i )
    {
        SChannel* channel = query_channel( *i );

        channel->user_set.erase( role_id );
    }
}

void online( uint32 role_id )
{
    std::map< uint32, std::set< uint64 > >::iterator iter = user_set().find( role_id );
    if ( iter == user_set().end() )
        return;

    for ( std::set< uint64 >::iterator i = iter->second.begin();
        i != iter->second.end();
        ++i )
    {
        SChannel* channel = query_channel( *i );

        std::set< uint32 >::iterator j = channel->user_set.find( role_id );
        if ( j == channel->user_set.end() )
            channel->user_set.insert( role_id );
    }
}

uint32 cast_interval( SChannel* channel )
{
    if ( channel->user_set.size() < 10 )
        return 200;
    if ( channel->user_set.size() < 50 )
        return 500;
    if ( channel->user_set.size() < 150 )
        return 1000;

    return 1500;
}
void cast_progress( SChannel* channel )
{
    uint32 tag_size = sizeof( tag_pack_head );
    if ( channel->stream.length() <= tag_size )
        return;

    tag_pack_head* head = (tag_pack_head*)&channel->stream[0];
    CPack::fill_pack_head( head, &channel->stream[ tag_size ], channel->stream.length() - tag_size );

    std::set< int32 > set;
    for ( std::set< uint32 >::iterator iter = channel->user_set.begin();
        iter != channel->user_set.end();
        ++iter )
    {
        user::SData* user = user::find( *iter );

        //数据直发, 不缓存广播数据
        if ( user != NULL && user->sock != 0 )
        {
            if ( set.find( user->sock ) != set.end() )
            {
                LOG_ERROR( "cache::cast_progress: set.find( user->sock ) != set.end()" );
                continue;
            }

            set.insert( user->sock );
            theNet.Write( user->sock, &channel->stream[0], channel->stream.length() );
        }
    }
    channel->stream.clear();
}
void progress( uint64 value/* = 0*/ )
{
    uint64 msec = GetMSec().ToMSec();

    if ( value != 0 )
    {
        SChannel* channel = query_channel( value );
        if ( msec >= channel->next_time )
        {
            cast_progress( channel );

            channel->next_time = msec + cast_interval( channel );
        }
        return;
    }

    for ( std::map< uint64, SChannel* >::iterator iter = channel_map().begin();
        iter != channel_map().end();
        ++iter )
    {
        SChannel* channel = iter->second;
        if ( msec >= channel->next_time )
        {
            cast_progress( channel );

            channel->next_time = msec + cast_interval( channel );
        }
    }
}

}// namespace cache

