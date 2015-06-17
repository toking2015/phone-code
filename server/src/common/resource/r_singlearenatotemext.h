#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENATOTEMEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENATOTEMEXT_H_

#include "r_singlearenatotemdata.h"

class CSingleArenaTotemExt : public CSingleArenaTotemData
{
private:
    std::map<uint32, std::vector<SData*> > rank_map;

public:
    ~CSingleArenaTotemExt();
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SingleArenaTotemMap::iterator iter = id_singlearenatotem_map.begin();
            iter != id_singlearenatotem_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    void LoadData();
    void ClearData();
    std::vector<uint32> GetTotem( uint32 rank );
};

#define theSingleArenaTotemExt TSignleton<CSingleArenaTotemExt>::Ref()
#endif
