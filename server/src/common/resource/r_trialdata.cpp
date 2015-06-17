#include "jsonconfig.h"
#include "r_trialdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTrialData::CTrialData()
{
}

CTrialData::~CTrialData()
{
    resource_clear(id_trial_map);
}

void CTrialData::LoadData(void)
{
    CJson jc = CJson::Load( "Trial" );

    theResDataMgr.insert(this);
    resource_clear(id_trial_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptrial                        = new SData;
        ptrial->id                              = to_uint(aj[i]["id"]);
        ptrial->name                            = to_str(aj[i]["name"]);
        uint32 open_day;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "open_day%d", j);
            open_day = to_uint(aj[i][buff]);
            ptrial->open_day.push_back(open_day);
        }
        ptrial->strength_cost                   = to_uint(aj[i]["strength_cost"]);
        ptrial->try_count                       = to_uint(aj[i]["try_count"]);
        ptrial->monster_id                      = to_uint(aj[i]["monster_id"]);
        ptrial->trial_occu                      = to_uint(aj[i]["trial_occu"]);
        S2UInt32 occu_odd;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "occu_odd%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &occu_odd.first, &occu_odd.second ) )
                break;
            ptrial->occu_odd.push_back(occu_odd);
        }
        ptrial->desc                            = to_str(aj[i]["desc"]);

        Add(ptrial);
        ++count;
        LOG_DEBUG("id:%u,name:%s,strength_cost:%u,try_count:%u,monster_id:%u,trial_occu:%u,desc:%s,", ptrial->id, ptrial->name.c_str(), ptrial->strength_cost, ptrial->try_count, ptrial->monster_id, ptrial->trial_occu, ptrial->desc.c_str());
    }
    LOG_INFO("Trial.xls:%d", count);
}

void CTrialData::ClearData(void)
{
    for( UInt32TrialMap::iterator iter = id_trial_map.begin();
        iter != id_trial_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_trial_map.clear();
}

CTrialData::SData* CTrialData::Find( uint32 id )
{
    UInt32TrialMap::iterator iter = id_trial_map.find(id);
    if ( iter != id_trial_map.end() )
        return iter->second;
    return NULL;
}

void CTrialData::Add(SData* ptrial)
{
    id_trial_map[ptrial->id] = ptrial;
}
