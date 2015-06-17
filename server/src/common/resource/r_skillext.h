#ifndef IMMORTAL_COMMON_RESOURCE_R_SKILLEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SKILLEXT_H_

#include "r_skilldata.h"

class CSkillExt : public CSkillData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SkillMap::iterator iter = id_skill_map.begin();
            iter != id_skill_map.end();
            ++iter )
        {
            for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
                jter != iter->second.end();
                ++jter )
            {
                if ( !call( jter->second ) )
                    break;
            }
        }
    }
};

#define theSkillExt TSignleton<CSkillExt>::Ref()
#endif
