#ifndef IMMORTAL_COMMON_RESOURCE_R_TASKDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TASKDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTaskData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  task_id;
        uint32                                  front_id;
        uint32                                  copy_id;
        uint32                                  type;
        std::string                             name;
        uint32                                  team_level_min;
        uint32                                  team_level_max;
        S3UInt32                                cond;
        uint32                                  begin_gut;
        uint32                                  end_gut;
        std::vector<S3UInt32>                   coins;
        std::string                             activity;
        uint32                                  auto_submit;
    };

	typedef std::map<uint32, SData*> UInt32TaskMap;

	CTaskData();
	virtual ~CTaskData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 task_id );
protected:
	UInt32TaskMap id_task_map;
	void Add(SData* task);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TASKMGR_H_
