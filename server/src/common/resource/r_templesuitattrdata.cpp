#include "jsonconfig.h"
#include "r_templesuitattrdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleSuitAttrData::CTempleSuitAttrData()
{
}

CTempleSuitAttrData::~CTempleSuitAttrData()
{
    resource_clear(id_templesuitattr_map);
}

void CTempleSuitAttrData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleSuitAttr" );

    theResDataMgr.insert(this);
    resource_clear(id_templesuitattr_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptemplesuitattr               = new SData;
        ptemplesuitattr->id                              = to_uint(aj[i]["id"]);
        ptemplesuitattr->type                            = to_uint(aj[i]["type"]);
        ptemplesuitattr->cond_exp                        = to_uint(aj[i]["cond_exp"]);
        ptemplesuitattr->cond_quality                    = to_uint(aj[i]["cond_quality"]);
        ptemplesuitattr->cond_count                      = to_uint(aj[i]["cond_count"]);
        S2UInt32 odds;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "odds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &odds.first, &odds.second ) )
                break;
            ptemplesuitattr->odds.push_back(odds);
        }

        Add(ptemplesuitattr);
        ++count;
        LOG_DEBUG("id:%u,type:%u,cond_exp:%u,cond_quality:%u,cond_count:%u,", ptemplesuitattr->id, ptemplesuitattr->type, ptemplesuitattr->cond_exp, ptemplesuitattr->cond_quality, ptemplesuitattr->cond_count);
    }
    LOG_INFO("TempleSuitAttr.xls:%d", count);
}

void CTempleSuitAttrData::ClearData(void)
{
    for( UInt32TempleSuitAttrMap::iterator iter = id_templesuitattr_map.begin();
        iter != id_templesuitattr_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_templesuitattr_map.clear();
}

CTempleSuitAttrData::SData* CTempleSuitAttrData::Find( uint32 id )
{
    UInt32TempleSuitAttrMap::iterator iter = id_templesuitattr_map.find(id);
    if ( iter != id_templesuitattr_map.end() )
        return iter->second;
    return NULL;
}

void CTempleSuitAttrData::Add(SData* ptemplesuitattr)
{
    id_templesuitattr_map[ptemplesuitattr->id] = ptemplesuitattr;
}
