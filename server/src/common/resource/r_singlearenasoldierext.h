#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENASOLDIEREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENASOLDIEREXT_H_

#include "r_singlearenasoldierdata.h"

class CSingleArenaSoldierExt : public CSingleArenaSoldierData
{
private:
    std::map<uint32, std::vector<SData*> > rank_map;

public:
    ~CSingleArenaSoldierExt();
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SingleArenaSoldierMap::iterator iter = id_singlearenasoldier_map.begin();
            iter != id_singlearenasoldier_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    void LoadData();
    void ClearData();
    std::vector<uint32> GetSoldier( uint32 rank );
};

#define theSingleArenaSoldierExt TSignleton<CSingleArenaSoldierExt>::Ref()
#endif
