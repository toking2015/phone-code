#include "jsonconfig.h"
#include "r_biasdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBiasData::CBiasData()
{
}

CBiasData::~CBiasData()
{
    resource_clear(id_bias_map);
}

void CBiasData::LoadData(void)
{
    CJson jc = CJson::Load( "Bias" );

    theResDataMgr.insert(this);
    resource_clear(id_bias_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbias                         = new SData;
        pbias->id                              = to_uint(aj[i]["id"]);
        pbias->begin_count                     = to_uint(aj[i]["begin_count"]);
        pbias->must_count                      = to_uint(aj[i]["must_count"]);
        pbias->begin_factor                    = to_uint(aj[i]["begin_factor"]);
        pbias->add_factor                      = to_uint(aj[i]["add_factor"]);
        pbias->day_count                       = to_uint(aj[i]["day_count"]);
        pbias->back_id                         = to_uint(aj[i]["back_id"]);

        Add(pbias);
        ++count;
        LOG_DEBUG("id:%u,begin_count:%u,must_count:%u,begin_factor:%u,add_factor:%u,day_count:%u,back_id:%u,", pbias->id, pbias->begin_count, pbias->must_count, pbias->begin_factor, pbias->add_factor, pbias->day_count, pbias->back_id);
    }
    LOG_INFO("Bias.xls:%d", count);
}

void CBiasData::ClearData(void)
{
    for( UInt32BiasMap::iterator iter = id_bias_map.begin();
        iter != id_bias_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_bias_map.clear();
}

CBiasData::SData* CBiasData::Find( uint32 id )
{
    UInt32BiasMap::iterator iter = id_bias_map.find(id);
    if ( iter != id_bias_map.end() )
        return iter->second;
    return NULL;
}

void CBiasData::Add(SData* pbias)
{
    id_bias_map[pbias->id] = pbias;
}
