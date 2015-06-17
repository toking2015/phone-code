#include "jsonconfig.h"
#include "r_soldierstardata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierStarData::CSoldierStarData()
{
}

CSoldierStarData::~CSoldierStarData()
{
    resource_clear(id_soldierstar_map);
}

void CSoldierStarData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierStar" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierstar_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierstar                  = new SData;
        psoldierstar->lv                              = to_uint(aj[i]["lv"]);
        psoldierstar->cost                            = to_uint(aj[i]["cost"]);
        std::string need_money_string = aj[i]["need_money"].asString();
        sscanf( need_money_string.c_str(), "%u%%%u%%%u", &psoldierstar->need_money.cate, &psoldierstar->need_money.objid, &psoldierstar->need_money.val );
        psoldierstar->grow                            = to_uint(aj[i]["grow"]);

        Add(psoldierstar);
        ++count;
        LOG_DEBUG("lv:%u,cost:%u,grow:%u,", psoldierstar->lv, psoldierstar->cost, psoldierstar->grow);
    }
    LOG_INFO("SoldierStar.xls:%d", count);
}

void CSoldierStarData::ClearData(void)
{
    for( UInt32SoldierStarMap::iterator iter = id_soldierstar_map.begin();
        iter != id_soldierstar_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierstar_map.clear();
}

CSoldierStarData::SData* CSoldierStarData::Find( uint32 lv )
{
    UInt32SoldierStarMap::iterator iter = id_soldierstar_map.find(lv);
    if ( iter != id_soldierstar_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierStarData::Add(SData* psoldierstar)
{
    id_soldierstar_map[psoldierstar->lv] = psoldierstar;
}
