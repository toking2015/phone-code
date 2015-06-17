#ifndef _CODER_H_
#define _CODER_H_

#include <weedong/core/os.h>

uint32 checksum_bytes( void* bytes, int32 posi, int32 len );

void encode_bytes( void* bytes, int32 posi, int32 len, int32 key );
void decode_bytes( void* bytes, int32 posi, int32 len, int32 key );

#endif

