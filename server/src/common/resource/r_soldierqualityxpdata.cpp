#include "jsonconfig.h"
#include "r_soldierqualityxpdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierQualityXpData::CSoldierQualityXpData()
{
}

CSoldierQualityXpData::~CSoldierQualityXpData()
{
    resource_clear(id_soldierqualityxp_map);
}

void CSoldierQualityXpData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierQualityXp" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierqualityxp_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierqualityxp             = new SData;
        psoldierqualityxp->id                              = to_uint(aj[i]["id"]);
        std::string coin_string = aj[i]["coin"].asString();
        sscanf( coin_string.c_str(), "%u%%%u%%%u", &psoldierqualityxp->coin.cate, &psoldierqualityxp->coin.objid, &psoldierqualityxp->coin.val );
        std::string quality_lv_string = aj[i]["quality_lv"].asString();
        sscanf( quality_lv_string.c_str(), "%u%%%u", &psoldierqualityxp->quality_lv.first, &psoldierqualityxp->quality_lv.second );
        psoldierqualityxp->quality_xp                      = to_uint(aj[i]["quality_xp"]);

        Add(psoldierqualityxp);
        ++count;
        LOG_DEBUG("id:%u,quality_xp:%u,", psoldierqualityxp->id, psoldierqualityxp->quality_xp);
    }
    LOG_INFO("SoldierQualityXp.xls:%d", count);
}

void CSoldierQualityXpData::ClearData(void)
{
    for( UInt32SoldierQualityXpMap::iterator iter = id_soldierqualityxp_map.begin();
        iter != id_soldierqualityxp_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierqualityxp_map.clear();
}

CSoldierQualityXpData::SData* CSoldierQualityXpData::Find( uint32 id )
{
    UInt32SoldierQualityXpMap::iterator iter = id_soldierqualityxp_map.find(id);
    if ( iter != id_soldierqualityxp_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierQualityXpData::Add(SData* psoldierqualityxp)
{
    id_soldierqualityxp_map[psoldierqualityxp->id] = psoldierqualityxp;
}
