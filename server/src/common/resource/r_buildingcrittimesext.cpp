#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_buildingcrittimesext.h"

std::vector<S2UInt32> CBuildingCritTimesExt::FindList( uint32 building_type )
{
    std::vector<S2UInt32> list;
    list.clear();

    UInt32BuildingCritTimesMap::iterator iter = id_buildingcrittimes_map.find(building_type);
    if ( iter != id_buildingcrittimes_map.end() )
        return iter->second->times;

    return list;
}

