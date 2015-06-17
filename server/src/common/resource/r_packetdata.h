#ifndef IMMORTAL_COMMON_RESOURCE_R_PACKETDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_PACKETDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CPacketData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::vector<S2UInt32>                   reward;
        uint32                                  bias_id;
    };

	typedef std::map<uint32, SData*> UInt32PacketMap;

	CPacketData();
	virtual ~CPacketData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32PacketMap id_packet_map;
	void Add(SData* packet);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_PACKETMGR_H_
