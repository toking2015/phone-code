#ifndef IMMORTAL_COMMON_RESOURCE_R_SIGNDAYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SIGNDAYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSignDayData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             date;
        std::vector<S3UInt32>                   rewards;
        std::vector<S3UInt32>                   haohua_rewards;
    };

	typedef std::map<uint32, SData*> UInt32SignDayMap;

	CSignDayData();
	virtual ~CSignDayData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SignDayMap id_signday_map;
	void Add(SData* signday);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SIGNDAYMGR_H_
