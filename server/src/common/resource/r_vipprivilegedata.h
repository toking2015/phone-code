#ifndef IMMORTAL_COMMON_RESOURCE_R_VIPPRIVILEGEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_VIPPRIVILEGEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CVipPrivilegeData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        std::vector<uint32>                     vip;
    };

	typedef std::map<uint32, SData*> UInt32VipPrivilegeMap;

	CVipPrivilegeData();
	virtual ~CVipPrivilegeData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32VipPrivilegeMap id_vipprivilege_map;
	void Add(SData* vipprivilege);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_VIPPRIVILEGEMGR_H_
