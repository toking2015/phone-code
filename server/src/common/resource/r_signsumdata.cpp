#include "jsonconfig.h"
#include "r_signsumdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSignSumData::CSignSumData()
{
}

CSignSumData::~CSignSumData()
{
    resource_clear(id_signsum_map);
}

void CSignSumData::LoadData(void)
{
    CJson jc = CJson::Load( "SignSum" );

    theResDataMgr.insert(this);
    resource_clear(id_signsum_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psignsum                      = new SData;
        psignsum->id                              = to_uint(aj[i]["id"]);
        psignsum->sum_days                        = to_uint(aj[i]["sum_days"]);
        S3UInt32 rewards;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "rewards%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &rewards.cate, &rewards.objid, &rewards.val ) )
                break;
            psignsum->rewards.push_back(rewards);
        }

        Add(psignsum);
        ++count;
        LOG_DEBUG("id:%u,sum_days:%u,", psignsum->id, psignsum->sum_days);
    }
    LOG_INFO("SignSum.xls:%d", count);
}

void CSignSumData::ClearData(void)
{
    for( UInt32SignSumMap::iterator iter = id_signsum_map.begin();
        iter != id_signsum_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_signsum_map.clear();
}

CSignSumData::SData* CSignSumData::Find( uint32 id )
{
    UInt32SignSumMap::iterator iter = id_signsum_map.find(id);
    if ( iter != id_signsum_map.end() )
        return iter->second;
    return NULL;
}

void CSignSumData::Add(SData* psignsum)
{
    id_signsum_map[psignsum->id] = psignsum;
}
