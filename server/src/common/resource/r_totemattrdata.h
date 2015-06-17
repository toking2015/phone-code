#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMATTRDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMATTRDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTotemAttrData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        S2UInt32                                speed;
        S2UInt32                                skill;
        S2UInt32                                wake;
        std::string                             formation_add_position;
        S2UInt32                                formation_add_attr;
        std::string                             formation_up_desc;
        uint32                                  energy_time;
        std::vector<S3UInt32>                   train_cost;
        std::vector<S3UInt32>                   accelerate_cost;
        uint32                                  acc_count;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32TotemAttrMap;

	CTotemAttrData();
	virtual ~CTotemAttrData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32TotemAttrMap id_totemattr_map;
	void Add(SData* totemattr);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOTEMATTRMGR_H_
