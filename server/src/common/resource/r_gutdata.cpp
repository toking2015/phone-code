#include "jsonconfig.h"
#include "r_gutdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CGutData::CGutData()
{
}

CGutData::~CGutData()
{
    resource_clear(id_gut_map);
}

void CGutData::LoadData(void)
{
    CJson jc = CJson::Load( "Gut" );

    theResDataMgr.insert(this);
    resource_clear(id_gut_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pgut                          = new SData;
        pgut->id                              = to_uint(aj[i]["id"]);
        pgut->step                            = to_uint(aj[i]["step"]);
        pgut->type                            = to_uint(aj[i]["type"]);
        pgut->target                          = to_uint(aj[i]["target"]);
        pgut->face                            = to_uint(aj[i]["face"]);
        pgut->move_face                       = to_uint(aj[i]["move_face"]);
        pgut->move_speed                      = to_uint(aj[i]["move_speed"]);
        pgut->attr                            = to_uint(aj[i]["attr"]);
        pgut->talk                            = to_str(aj[i]["talk"]);
        pgut->monster                         = to_uint(aj[i]["monster"]);
        pgut->reward                          = to_uint(aj[i]["reward"]);
        pgut->box                             = to_uint(aj[i]["box"]);
        pgut->video                           = to_str(aj[i]["video"]);
        pgut->sound                           = to_str(aj[i]["sound"]);
        pgut->weather                         = to_uint(aj[i]["weather"]);
        pgut->shock                           = to_uint(aj[i]["shock"]);
        pgut->shaking_screen                  = to_uint(aj[i]["shaking_screen"]);
        pgut->red_screen                      = to_uint(aj[i]["red_screen"]);
        pgut->special                         = to_str(aj[i]["special"]);
        std::string take_coin_string = aj[i]["take_coin"].asString();
        sscanf( take_coin_string.c_str(), "%u%%%u%%%u", &pgut->take_coin.cate, &pgut->take_coin.objid, &pgut->take_coin.val );

        Add(pgut);
        ++count;
        LOG_DEBUG("id:%u,step:%u,type:%u,target:%u,face:%u,move_face:%u,move_speed:%u,attr:%u,talk:%s,monster:%u,reward:%u,box:%u,video:%s,sound:%s,weather:%u,shock:%u,shaking_screen:%u,red_screen:%u,special:%s,", pgut->id, pgut->step, pgut->type, pgut->target, pgut->face, pgut->move_face, pgut->move_speed, pgut->attr, pgut->talk.c_str(), pgut->monster, pgut->reward, pgut->box, pgut->video.c_str(), pgut->sound.c_str(), pgut->weather, pgut->shock, pgut->shaking_screen, pgut->red_screen, pgut->special.c_str());
    }
    LOG_INFO("Gut.xls:%d", count);
}

void CGutData::ClearData(void)
{
    for( UInt32GutMap::iterator iter = id_gut_map.begin();
        iter != id_gut_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_gut_map.clear();
}

CGutData::SData* CGutData::Find( uint32 id,uint32 step )
{
    return id_gut_map[id][step];
}

void CGutData::Add(SData* pgut)
{
    id_gut_map[pgut->id][pgut->step] = pgut;
}
