#include "local.h"
#include "msg.h"
#include "netsingle.h"
#include "pack.h"

namespace local
{

void post( int32 key, SMsgHead& msg )
{
    wd::CStream stream;
    stream << msg;

    theMsg.Post( 0, key, &stream[0], stream.length() );
}

void send( int32 key, SMsgHead& msg )
{
    wd::CStream stream;
    stream << msg;

    theMsg.Send( 0, key, &stream[0], stream.length() );
}

void write( int32 local_id, SMsgHead& msg )
{
    if ( local_id == local::self )
    {
        post( local_id, msg );
        return;
    }

    wd::CStream stream;
    stream.resize( sizeof( tag_pack_head ) );
    stream << msg;

    CPack::fill_pack_head
    (
        (tag_pack_head*)&stream[0],
        &stream[ sizeof( tag_pack_head ) ],
        stream.length() - sizeof( tag_pack_head )
    );

    net::write( local_id, &stream[0], stream.length() );
}

void broadcast( SMsgHead& msg )
{
    wd::CStream stream;
    stream.resize( sizeof( tag_pack_head ) );
    stream << msg;

    CPack::fill_pack_head
    (
        (tag_pack_head*)&stream[0],
        &stream[ sizeof( tag_pack_head ) ],
        stream.length() - sizeof( tag_pack_head )
    );

    net::broadcast( &stream[0], stream.length() );
}

}// namespace local

