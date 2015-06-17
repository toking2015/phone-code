#include "jsonconfig.h"
#include "r_soldierrecruitdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierRecruitData::CSoldierRecruitData()
{
}

CSoldierRecruitData::~CSoldierRecruitData()
{
    resource_clear(id_soldierrecruit_map);
}

void CSoldierRecruitData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierRecruit" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierrecruit_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierrecruit               = new SData;
        psoldierrecruit->id                              = to_uint(aj[i]["id"]);
        psoldierrecruit->soldier_id                      = to_uint(aj[i]["soldier_id"]);
        S3UInt32 cost_;
        for ( uint32 j = 1; j <= 2; ++j )
        {
            std::string buff = strprintf( "cost_%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &cost_.cate, &cost_.objid, &cost_.val ) )
                break;
            psoldierrecruit->cost_.push_back(cost_);
        }

        Add(psoldierrecruit);
        ++count;
        LOG_DEBUG("id:%u,soldier_id:%u,", psoldierrecruit->id, psoldierrecruit->soldier_id);
    }
    LOG_INFO("SoldierRecruit.xls:%d", count);
}

void CSoldierRecruitData::ClearData(void)
{
    for( UInt32SoldierRecruitMap::iterator iter = id_soldierrecruit_map.begin();
        iter != id_soldierrecruit_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierrecruit_map.clear();
}

CSoldierRecruitData::SData* CSoldierRecruitData::Find( uint32 id )
{
    UInt32SoldierRecruitMap::iterator iter = id_soldierrecruit_map.find(id);
    if ( iter != id_soldierrecruit_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierRecruitData::Add(SData* psoldierrecruit)
{
    id_soldierrecruit_map[psoldierrecruit->id] = psoldierrecruit;
}
