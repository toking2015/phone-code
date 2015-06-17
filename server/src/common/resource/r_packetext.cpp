#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_packetext.h"
#include "util.h"

uint32 packet_reward_get_value( S2UInt32& data )
{
    return data.second;
}
uint32 CPacketExt::RandomReward( uint32 packet_id )
{
    CPacketData::SData* data = Find( packet_id );
    if ( data == NULL )
        return 0;

    S2UInt32 reward = round_rand( data->reward, packet_reward_get_value );
    return reward.first;
}

