#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_buildingcostext.h"

uint32 CBuildingCostExt::GetMaxTimes()
{
    return  (uint32)id_buildingcost_map.size();
}

