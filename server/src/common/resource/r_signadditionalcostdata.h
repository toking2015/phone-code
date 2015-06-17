#ifndef IMMORTAL_COMMON_RESOURCE_R_SIGNADDITIONALCOSTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SIGNADDITIONALCOSTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSignAdditionalCostData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  days;
        S3UInt32                                cost;
    };

	typedef std::map<uint32, SData*> UInt32SignAdditionalCostMap;

	CSignAdditionalCostData();
	virtual ~CSignAdditionalCostData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 days );
protected:
	UInt32SignAdditionalCostMap id_signadditionalcost_map;
	void Add(SData* signadditionalcost);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SIGNADDITIONALCOSTMGR_H_
