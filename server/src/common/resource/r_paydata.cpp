#include "jsonconfig.h"
#include "r_paydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CPayData::CPayData()
{
}

CPayData::~CPayData()
{
    resource_clear(id_pay_map);
}

void CPayData::LoadData(void)
{
    CJson jc = CJson::Load( "Pay" );

    theResDataMgr.insert(this);
    resource_clear(id_pay_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ppay                          = new SData;
        ppay->pay                             = to_uint(aj[i]["pay"]);
        ppay->icon                            = to_uint(aj[i]["icon"]);
        uint32 present;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "present%d", j);
            present = to_uint(aj[i][buff]);
            ppay->present.push_back(present);
        }

        Add(ppay);
        ++count;
        LOG_DEBUG("pay:%u,icon:%u,", ppay->pay, ppay->icon);
    }
    LOG_INFO("Pay.xls:%d", count);
}

void CPayData::ClearData(void)
{
    for( UInt32PayMap::iterator iter = id_pay_map.begin();
        iter != id_pay_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_pay_map.clear();
}

CPayData::SData* CPayData::Find( uint32 pay )
{
    UInt32PayMap::iterator iter = id_pay_map.find(pay);
    if ( iter != id_pay_map.end() )
        return iter->second;
    return NULL;
}

void CPayData::Add(SData* ppay)
{
    id_pay_map[ppay->pay] = ppay;
}
