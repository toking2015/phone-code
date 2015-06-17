#include "jsonconfig.h"
#include "r_opentargetdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

COpenTargetData::COpenTargetData()
{
}

COpenTargetData::~COpenTargetData()
{
    resource_clear(id_opentarget_map);
}

void COpenTargetData::LoadData(void)
{
    CJson jc = CJson::Load( "OpenTarget" );

    theResDataMgr.insert(this);
    resource_clear(id_opentarget_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *popentarget                   = new SData;
        popentarget->day                             = to_uint(aj[i]["day"]);
        popentarget->id                              = to_uint(aj[i]["id"]);
        popentarget->a_type                          = to_uint(aj[i]["a_type"]);
        popentarget->if_type                         = to_uint(aj[i]["if_type"]);
        popentarget->if_value_1                      = to_uint(aj[i]["if_value_1"]);
        popentarget->if_value_2                      = to_uint(aj[i]["if_value_2"]);
        S3UInt32 item;
        for ( uint32 j = 1; j <= 2; ++j )
        {
            std::string buff = strprintf( "item%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &item.cate, &item.objid, &item.val ) )
                break;
            popentarget->item.push_back(item);
        }
        std::string coin_1_string = aj[i]["coin_1"].asString();
        sscanf( coin_1_string.c_str(), "%u%%%u%%%u", &popentarget->coin_1.cate, &popentarget->coin_1.objid, &popentarget->coin_1.val );
        S3UInt32 reward;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "reward%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &reward.cate, &reward.objid, &reward.val ) )
                break;
            popentarget->reward.push_back(reward);
        }
        popentarget->name                            = to_str(aj[i]["name"]);
        popentarget->desc                            = to_str(aj[i]["desc"]);

        Add(popentarget);
        ++count;
        LOG_DEBUG("day:%u,id:%u,a_type:%u,if_type:%u,if_value_1:%u,if_value_2:%u,name:%s,desc:%s,", popentarget->day, popentarget->id, popentarget->a_type, popentarget->if_type, popentarget->if_value_1, popentarget->if_value_2, popentarget->name.c_str(), popentarget->desc.c_str());
    }
    LOG_INFO("OpenTarget.xls:%d", count);
}

void COpenTargetData::ClearData(void)
{
    for( UInt32OpenTargetMap::iterator iter = id_opentarget_map.begin();
        iter != id_opentarget_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_opentarget_map.clear();
}

COpenTargetData::SData* COpenTargetData::Find( uint32 day,uint32 id )
{
    return id_opentarget_map[day][id];
}

void COpenTargetData::Add(SData* popentarget)
{
    id_opentarget_map[popentarget->day][popentarget->id] = popentarget;
}
