#include "jsonconfig.h"
#include "r_signdaydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSignDayData::CSignDayData()
{
}

CSignDayData::~CSignDayData()
{
    resource_clear(id_signday_map);
}

void CSignDayData::LoadData(void)
{
    CJson jc = CJson::Load( "SignDay" );

    theResDataMgr.insert(this);
    resource_clear(id_signday_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psignday                      = new SData;
        psignday->id                              = to_uint(aj[i]["id"]);
        psignday->date                            = to_str(aj[i]["date"]);
        S3UInt32 rewards;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "rewards%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &rewards.cate, &rewards.objid, &rewards.val ) )
                break;
            psignday->rewards.push_back(rewards);
        }
        S3UInt32 haohua_rewards;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "haohua_rewards%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &haohua_rewards.cate, &haohua_rewards.objid, &haohua_rewards.val ) )
                break;
            psignday->haohua_rewards.push_back(haohua_rewards);
        }

        Add(psignday);
        ++count;
        LOG_DEBUG("id:%u,date:%s,", psignday->id, psignday->date.c_str());
    }
    LOG_INFO("SignDay.xls:%d", count);
}

void CSignDayData::ClearData(void)
{
    for( UInt32SignDayMap::iterator iter = id_signday_map.begin();
        iter != id_signday_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_signday_map.clear();
}

CSignDayData::SData* CSignDayData::Find( uint32 id )
{
    UInt32SignDayMap::iterator iter = id_signday_map.find(id);
    if ( iter != id_signday_map.end() )
        return iter->second;
    return NULL;
}

void CSignDayData::Add(SData* psignday)
{
    id_signday_map[psignday->id] = psignday;
}
