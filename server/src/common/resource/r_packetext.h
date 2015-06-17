#ifndef IMMORTAL_COMMON_RESOURCE_R_PACKETEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_PACKETEXT_H_

#include "r_packetdata.h"

class CPacketExt : public CPacketData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32PacketMap::iterator iter = id_packet_map.begin();
            iter != id_packet_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    //获取掉落包随机指定的 reward_id, 需根据 theRewardExt 获得 reward 相关货币列表
    uint32 RandomReward( uint32 packet_id );
};

#define thePacketExt TSignleton<CPacketExt>::Ref()
#endif
