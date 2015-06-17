#ifndef IMMORTAL_COMMON_RESOURCE_R_PAPERCREATEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_PAPERCREATEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CPaperCreateData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  item_id;
        uint32                                  active_score;
        uint32                                  level_limit;
        uint32                                  skill_type;
    };

	typedef std::map<uint32, SData*> UInt32PaperCreateMap;

	CPaperCreateData();
	virtual ~CPaperCreateData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 item_id );
protected:
	UInt32PaperCreateMap id_papercreate_map;
	void Add(SData* papercreate);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_PAPERCREATEMGR_H_
