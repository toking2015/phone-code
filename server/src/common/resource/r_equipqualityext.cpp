#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_equipqualityext.h"

uint32 CEquipQualityExt::FactorToQuality(uint32 factor)
{
    for (UInt32EquipQualityMap::iterator iter = id_equipquality_map.begin();
        iter != id_equipquality_map.end();
        ++iter)
    {
        SData *p_data = iter->second;
        if (p_data->main_min < factor && factor < p_data->main_max)
            return p_data->quality;
    }
    return 0;
}
