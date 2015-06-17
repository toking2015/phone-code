#ifndef IMMORTAL_COMMON_RESOURCE_R_ACTIVITYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ACTIVITYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CActivityData : public CBaseData
{
public:
    struct SData
    {
        std::string                             name;
        uint32                                  cycle;
    };

	typedef std::map<std::string, SData*> UInt32ActivityMap;

	CActivityData();
	virtual ~CActivityData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( std::string name );
protected:
	UInt32ActivityMap id_activity_map;
	void Add(SData* activity);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ACTIVITYMGR_H_
