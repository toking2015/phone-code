#ifndef IMMORTAL_COMMON_RESOURCE_R_PAPERSKILLEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_PAPERSKILLEXT_H_

#include "r_paperskilldata.h"

class CPaperSkillExt : public CPaperSkillData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32PaperSkillMap::iterator iter = id_paperskill_map.begin();
            iter != id_paperskill_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    SData * FindByType(uint32 skill_type, uint32 level)
    {
        for ( UInt32PaperSkillMap::iterator iter = id_paperskill_map.begin();
            iter != id_paperskill_map.end();
            ++iter )
        {
            SData *p_data = iter->second;
            if (p_data->skill_type == skill_type && p_data->level == level)
                return p_data;
        }
        return NULL;
    }
};

#define thePaperSkillExt TSignleton<CPaperSkillExt>::Ref()
#endif
