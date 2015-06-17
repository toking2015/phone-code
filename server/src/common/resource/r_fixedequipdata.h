#ifndef IMMORTAL_COMMON_RESOURCE_R_FIXEDEQUIPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_FIXEDEQUIPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CFixedEquipData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  quality;
        uint32                                  main_factor;
        uint32                                  slave_factor;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32FixedEquipMap;

	CFixedEquipData();
	virtual ~CFixedEquipData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 quality );

protected:
	UInt32FixedEquipMap id_fixedequip_map;
	void Add(SData* fixedequip);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_FIXEDEQUIPMGR_H_
