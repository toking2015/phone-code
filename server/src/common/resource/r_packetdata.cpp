#include "jsonconfig.h"
#include "r_packetdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CPacketData::CPacketData()
{
}

CPacketData::~CPacketData()
{
    resource_clear(id_packet_map);
}

void CPacketData::LoadData(void)
{
    CJson jc = CJson::Load( "Packet" );

    theResDataMgr.insert(this);
    resource_clear(id_packet_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ppacket                       = new SData;
        ppacket->id                              = to_uint(aj[i]["id"]);
        S2UInt32 reward;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "reward%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &reward.first, &reward.second ) )
                break;
            ppacket->reward.push_back(reward);
        }
        ppacket->bias_id                         = to_uint(aj[i]["bias_id"]);

        Add(ppacket);
        ++count;
        LOG_DEBUG("id:%u,bias_id:%u,", ppacket->id, ppacket->bias_id);
    }
    LOG_INFO("Packet.xls:%d", count);
}

void CPacketData::ClearData(void)
{
    for( UInt32PacketMap::iterator iter = id_packet_map.begin();
        iter != id_packet_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_packet_map.clear();
}

CPacketData::SData* CPacketData::Find( uint32 id )
{
    UInt32PacketMap::iterator iter = id_packet_map.find(id);
    if ( iter != id_packet_map.end() )
        return iter->second;
    return NULL;
}

void CPacketData::Add(SData* ppacket)
{
    id_packet_map[ppacket->id] = ppacket;
}
