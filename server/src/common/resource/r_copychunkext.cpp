#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_copychunkext.h"
#include "util.h"

uint32 copy_chunk_get_value( S3UInt32& data )
{
    return data.val;
}
S3UInt32 CCopyChunkExt::Random( CCopyChunkData::SData* data )
{
    return round_rand( data->event, copy_chunk_get_value );
}
