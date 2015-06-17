#include <misc.h>

uint32 checksum_bytes( void* bytes, int32 posi, int32 len )
{
    uint32 sum = 0;

    for ( int32 end = posi + len; posi < end; ++posi )
        sum += ( (uint8*)bytes )[posi];

    return sum;
}

void encode_bytes( void* bytes, int32 posi, int32 len, int32 key )
{
    key ^= ENCODE_KEY;
    for ( int32 end = posi + len; posi < end; ++posi )
    {
        unsigned char value = ((unsigned char*)bytes)[ posi ];

        value = ~value;
        value ^= ( key & 0xFF );

        ((unsigned char*)bytes)[ posi ] = ( value & 0xFF );
    }
}

void decode_bytes( void* bytes, int32 posi, int32 len, int32 key )
{
    key ^= ENCODE_KEY;
    for ( int32 end = posi + len; posi < end; ++posi )
    {
        unsigned char value = ((unsigned char*)bytes)[ posi ];

        value ^= ( key & 0xFF );
        value = ~value;

        ((unsigned char*)bytes)[ posi ] = ( value & 0xFF );
    }
}

