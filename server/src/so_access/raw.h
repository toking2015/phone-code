#ifndef _IMMORTAL_SO_ACCESS_RAW_H_
#define _IMMORTAL_SO_ACCESS_RAW_H_

#include "common.h"
#include "pack.h"
#include "netio.h"

namespace raw
{
    template< typename T >
    void send_msg_whitout_session( int32 sock, T& msg )
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

        theNet.Write( sock, &stream[0], stream.length() );
    }

}// namespace raw

#endif
