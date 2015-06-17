#include "jsonconfig.h"
#include "r_rankcopydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CRankCopyData::CRankCopyData()
{
}

CRankCopyData::~CRankCopyData()
{
    resource_clear(id_rankcopy_map);
}

void CRankCopyData::LoadData(void)
{
    CJson jc = CJson::Load( "RankCopy" );

    theResDataMgr.insert(this);
    resource_clear(id_rankcopy_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *prankcopy                     = new SData;
        prankcopy->rank                            = to_uint(aj[i]["rank"]);
        prankcopy->cyc                             = to_uint(aj[i]["cyc"]);
        prankcopy->delay                           = to_uint(aj[i]["delay"]);
        prankcopy->time                            = to_str(aj[i]["time"]);

        Add(prankcopy);
        ++count;
        LOG_DEBUG("rank:%u,cyc:%u,delay:%u,time:%s,", prankcopy->rank, prankcopy->cyc, prankcopy->delay, prankcopy->time.c_str());
    }
    LOG_INFO("RankCopy.xls:%d", count);
}

void CRankCopyData::ClearData(void)
{
    for( UInt32RankCopyMap::iterator iter = id_rankcopy_map.begin();
        iter != id_rankcopy_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_rankcopy_map.clear();
}

CRankCopyData::SData* CRankCopyData::Find( uint32 rank )
{
    UInt32RankCopyMap::iterator iter = id_rankcopy_map.find(rank);
    if ( iter != id_rankcopy_map.end() )
        return iter->second;
    return NULL;
}

void CRankCopyData::Add(SData* prankcopy)
{
    id_rankcopy_map[prankcopy->rank] = prankcopy;
}
