#include "misc.h"
#include "proto/constant.h"
#include "proto/broadcast.h"
#include "cache.h"
#include "user.h"
#include "pro.h"

MSG_FUNC( PQBroadCastList )
{
    SO_PRO_ORDER_CHECK();

    std::vector< uint64 > value_list = cache::query_channel_list( msg.role_id );

    PRBroadCastList rep;
    bccopy( rep, msg );

    SUserChannel channel;
    for ( std::vector< uint64 >::iterator iter = value_list.begin();
        iter != value_list.end();
        ++iter )
    {
        cache::SChannel::SData data = cache::value_to_channel( *iter );

        channel.broad_cast = data.cast;
        channel.broad_type = data.type;
        channel.broad_id = data.id;

        rep.channel_list.push_back( channel );
    }

    user::write( 0, rep );
}

MSG_FUNC( PQBroadCastSet )
{
    SO_PRO_ORDER_CHECK();

    switch ( msg.set_type )
    {
    case kObjectAdd:
        {
            cache::set( msg.role_id, cache::channel_to_value( msg.broad_cast, msg.broad_type, msg.broad_id ) );
        }
        break;
    case kObjectDel:
        {
            cache::unset( msg.role_id, cache::channel_to_value( msg.broad_cast, msg.broad_type, msg.broad_id ) );
        }
        break;
    }
}
