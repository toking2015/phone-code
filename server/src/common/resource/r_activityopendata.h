#ifndef IMMORTAL_COMMON_RESOURCE_R_ACTIVITYOPENDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ACTIVITYOPENDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CActivityOpenData : public CBaseData
{
public:
    struct SData
    {
        std::string                             name;
        uint32                                  type;
        std::string                             first_time;
        uint32                                  second_time;
        std::string                             desc;
    };

	typedef std::map<std::string, std::map<uint32, SData*> >UInt32ActivityOpenMap;

	CActivityOpenData();
	virtual ~CActivityOpenData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( std::string name, uint32 type );

protected:
	UInt32ActivityOpenMap id_activityopen_map;
	void Add(SData* activityopen);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ACTIVITYOPENMGR_H_
