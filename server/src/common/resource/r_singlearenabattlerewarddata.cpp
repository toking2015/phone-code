#include "jsonconfig.h"
#include "r_singlearenabattlerewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSingleArenaBattleRewardData::CSingleArenaBattleRewardData()
{
}

CSingleArenaBattleRewardData::~CSingleArenaBattleRewardData()
{
    resource_clear(id_singlearenabattlereward_map);
}

void CSingleArenaBattleRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "SingleArenaBattleReward" );

    theResDataMgr.insert(this);
    resource_clear(id_singlearenabattlereward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psinglearenabattlereward         = new SData;
        psinglearenabattlereward->id                              = to_uint(aj[i]["id"]);
        psinglearenabattlereward->field_b                         = to_uint(aj[i]["field_b"]);
        psinglearenabattlereward->field_e                         = to_uint(aj[i]["field_e"]);
        psinglearenabattlereward->field_r                         = to_uint(aj[i]["field_r"]);
        psinglearenabattlereward->field_y                         = to_uint(aj[i]["field_y"]);

        Add(psinglearenabattlereward);
        ++count;
        LOG_DEBUG("id:%u,field_b:%u,field_e:%u,field_r:%u,field_y:%u,", psinglearenabattlereward->id, psinglearenabattlereward->field_b, psinglearenabattlereward->field_e, psinglearenabattlereward->field_r, psinglearenabattlereward->field_y);
    }
    LOG_INFO("SingleArenaBattleReward.xls:%d", count);
}

void CSingleArenaBattleRewardData::ClearData(void)
{
    for( UInt32SingleArenaBattleRewardMap::iterator iter = id_singlearenabattlereward_map.begin();
        iter != id_singlearenabattlereward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_singlearenabattlereward_map.clear();
}

CSingleArenaBattleRewardData::SData* CSingleArenaBattleRewardData::Find( uint32 id )
{
    UInt32SingleArenaBattleRewardMap::iterator iter = id_singlearenabattlereward_map.find(id);
    if ( iter != id_singlearenabattlereward_map.end() )
        return iter->second;
    return NULL;
}

void CSingleArenaBattleRewardData::Add(SData* psinglearenabattlereward)
{
    id_singlearenabattlereward_map[psinglearenabattlereward->id] = psinglearenabattlereward;
}
