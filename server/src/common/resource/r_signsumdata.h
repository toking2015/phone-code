#ifndef IMMORTAL_COMMON_RESOURCE_R_SIGNSUMDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SIGNSUMDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSignSumData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  sum_days;
        std::vector<S3UInt32>                   rewards;
    };

	typedef std::map<uint32, SData*> UInt32SignSumMap;

	CSignSumData();
	virtual ~CSignSumData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SignSumMap id_signsum_map;
	void Add(SData* signsum);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SIGNSUMMGR_H_
