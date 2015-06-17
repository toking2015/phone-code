#include "jsonconfig.h"
#include "r_signadditionalcostdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSignAdditionalCostData::CSignAdditionalCostData()
{
}

CSignAdditionalCostData::~CSignAdditionalCostData()
{
    resource_clear(id_signadditionalcost_map);
}

void CSignAdditionalCostData::LoadData(void)
{
    CJson jc = CJson::Load( "SignAdditionalCost" );

    theResDataMgr.insert(this);
    resource_clear(id_signadditionalcost_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psignadditionalcost           = new SData;
        psignadditionalcost->days                            = to_uint(aj[i]["days"]);
        std::string cost_string = aj[i]["cost"].asString();
        sscanf( cost_string.c_str(), "%u%%%u%%%u", &psignadditionalcost->cost.cate, &psignadditionalcost->cost.objid, &psignadditionalcost->cost.val );

        Add(psignadditionalcost);
        ++count;
        LOG_DEBUG("days:%u,", psignadditionalcost->days);
    }
    LOG_INFO("SignAdditionalCost.xls:%d", count);
}

void CSignAdditionalCostData::ClearData(void)
{
    for( UInt32SignAdditionalCostMap::iterator iter = id_signadditionalcost_map.begin();
        iter != id_signadditionalcost_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_signadditionalcost_map.clear();
}

CSignAdditionalCostData::SData* CSignAdditionalCostData::Find( uint32 days )
{
    UInt32SignAdditionalCostMap::iterator iter = id_signadditionalcost_map.find(days);
    if ( iter != id_signadditionalcost_map.end() )
        return iter->second;
    return NULL;
}

void CSignAdditionalCostData::Add(SData* psignadditionalcost)
{
    id_signadditionalcost_map[psignadditionalcost->days] = psignadditionalcost;
}
