#include "jsonconfig.h"
#include "r_copydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CCopyData::CCopyData()
{
}

CCopyData::~CCopyData()
{
    resource_clear(id_copy_map);
}

void CCopyData::LoadData(void)
{
    CJson jc = CJson::Load( "Copy" );

    theResDataMgr.insert(this);
    resource_clear(id_copy_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pcopy                         = new SData;
        pcopy->id                              = to_uint(aj[i]["id"]);
        pcopy->name                            = to_str(aj[i]["name"]);
        pcopy->type                            = to_uint(aj[i]["type"]);
        pcopy->level                           = to_uint(aj[i]["level"]);
        pcopy->task                            = to_uint(aj[i]["task"]);
        pcopy->guage                           = to_uint(aj[i]["guage"]);
        S3UInt32 boss_chunk;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "boss_chunk%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &boss_chunk.cate, &boss_chunk.objid, &boss_chunk.val ) )
                break;
            pcopy->boss_chunk.push_back(boss_chunk);
        }
        pcopy->pass_reward                     = to_uint(aj[i]["pass_reward"]);
        S3UInt32 pass_equip;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "pass_equip%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &pass_equip.cate, &pass_equip.objid, &pass_equip.val ) )
                break;
            pcopy->pass_equip.push_back(pass_equip);
        }
        S3UInt32 chunk;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "chunk%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &chunk.cate, &chunk.objid, &chunk.val ) )
                break;
            pcopy->chunk.push_back(chunk);
        }
        S2UInt32 reward;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "reward%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &reward.first, &reward.second ) )
                break;
            pcopy->reward.push_back(reward);
        }
        std::string mapid_string = aj[i]["mapid"].asString();
        sscanf( mapid_string.c_str(), "%u%%%u", &pcopy->mapid.first, &pcopy->mapid.second );
        pcopy->desc                            = to_str(aj[i]["desc"]);
        pcopy->icon                            = to_uint(aj[i]["icon"]);
        std::string pos_string = aj[i]["pos"].asString();
        sscanf( pos_string.c_str(), "%u%%%u", &pcopy->pos.first, &pcopy->pos.second );
        pcopy->foot_sound                      = to_str(aj[i]["foot_sound"]);
        pcopy->bg_sound                        = to_str(aj[i]["bg_sound"]);
        pcopy->drop_item                       = to_uint(aj[i]["drop_item"]);
        pcopy->elitedrop_item                  = to_uint(aj[i]["elitedrop_item"]);

        Add(pcopy);
        ++count;
        LOG_DEBUG("id:%u,name:%s,type:%u,level:%u,task:%u,guage:%u,pass_reward:%u,desc:%s,icon:%u,foot_sound:%s,bg_sound:%s,drop_item:%u,elitedrop_item:%u,", pcopy->id, pcopy->name.c_str(), pcopy->type, pcopy->level, pcopy->task, pcopy->guage, pcopy->pass_reward, pcopy->desc.c_str(), pcopy->icon, pcopy->foot_sound.c_str(), pcopy->bg_sound.c_str(), pcopy->drop_item, pcopy->elitedrop_item);
    }
    LOG_INFO("Copy.xls:%d", count);
}

void CCopyData::ClearData(void)
{
    for( UInt32CopyMap::iterator iter = id_copy_map.begin();
        iter != id_copy_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_copy_map.clear();
}

CCopyData::SData* CCopyData::Find( uint32 id )
{
    UInt32CopyMap::iterator iter = id_copy_map.find(id);
    if ( iter != id_copy_map.end() )
        return iter->second;
    return NULL;
}

void CCopyData::Add(SData* pcopy)
{
    id_copy_map[pcopy->id] = pcopy;
}
