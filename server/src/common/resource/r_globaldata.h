#ifndef IMMORTAL_COMMON_RESOURCE_R_GLOBALDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_GLOBALDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CGlobalData : public CBaseData
{
public:
    struct SData
    {
        std::string                             global_name;
        std::string                             data;
        std::string                             describe;
    };

	typedef std::map<std::string, SData*> UInt32GlobalMap;

	CGlobalData();
	virtual ~CGlobalData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( std::string global_name );
protected:
	UInt32GlobalMap id_global_map;
	void Add(SData* global);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_GLOBALMGR_H_
