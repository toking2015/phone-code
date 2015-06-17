#include "jsonconfig.h"
#include "r_taskdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTaskData::CTaskData()
{
}

CTaskData::~CTaskData()
{
    resource_clear(id_task_map);
}

void CTaskData::LoadData(void)
{
    CJson jc = CJson::Load( "Task" );

    theResDataMgr.insert(this);
    resource_clear(id_task_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptask                         = new SData;
        ptask->task_id                         = to_uint(aj[i]["task_id"]);
        ptask->front_id                        = to_uint(aj[i]["front_id"]);
        ptask->copy_id                         = to_uint(aj[i]["copy_id"]);
        ptask->type                            = to_uint(aj[i]["type"]);
        ptask->name                            = to_str(aj[i]["name"]);
        ptask->team_level_min                  = to_uint(aj[i]["team_level_min"]);
        ptask->team_level_max                  = to_uint(aj[i]["team_level_max"]);
        std::string cond_string = aj[i]["cond"].asString();
        sscanf( cond_string.c_str(), "%u%%%u%%%u", &ptask->cond.cate, &ptask->cond.objid, &ptask->cond.val );
        ptask->begin_gut                       = to_uint(aj[i]["begin_gut"]);
        ptask->end_gut                         = to_uint(aj[i]["end_gut"]);
        S3UInt32 coins;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "coins%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &coins.cate, &coins.objid, &coins.val ) )
                break;
            ptask->coins.push_back(coins);
        }
        ptask->activity                        = to_str(aj[i]["activity"]);
        ptask->auto_submit                     = to_uint(aj[i]["auto_submit"]);

        Add(ptask);
        ++count;
        LOG_DEBUG("task_id:%u,front_id:%u,copy_id:%u,type:%u,name:%s,team_level_min:%u,team_level_max:%u,begin_gut:%u,end_gut:%u,activity:%s,auto_submit:%u,", ptask->task_id, ptask->front_id, ptask->copy_id, ptask->type, ptask->name.c_str(), ptask->team_level_min, ptask->team_level_max, ptask->begin_gut, ptask->end_gut, ptask->activity.c_str(), ptask->auto_submit);
    }
    LOG_INFO("Task.xls:%d", count);
}

void CTaskData::ClearData(void)
{
    for( UInt32TaskMap::iterator iter = id_task_map.begin();
        iter != id_task_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_task_map.clear();
}

CTaskData::SData* CTaskData::Find( uint32 task_id )
{
    UInt32TaskMap::iterator iter = id_task_map.find(task_id);
    if ( iter != id_task_map.end() )
        return iter->second;
    return NULL;
}

void CTaskData::Add(SData* ptask)
{
    id_task_map[ptask->task_id] = ptask;
}
