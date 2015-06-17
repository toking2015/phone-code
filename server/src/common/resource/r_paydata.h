#ifndef IMMORTAL_COMMON_RESOURCE_R_PAYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_PAYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CPayData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  pay;
        uint32                                  icon;
        std::vector<uint32>                     present;
    };

	typedef std::map<uint32, SData*> UInt32PayMap;

	CPayData();
	virtual ~CPayData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 pay );
protected:
	UInt32PayMap id_pay_map;
	void Add(SData* pay);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_PAYMGR_H_
