#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYEXT_H_

#include "r_copydata.h"

class CCopyExt : public CCopyData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32CopyMap::iterator iter = id_copy_map.begin();
            iter != id_copy_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    virtual void LoadData(void);
    void ClearData(void);

    //上一个副本id
    uint32 GetFrontId( uint32 copy_id );

    //下一个副本id
    uint32 GetNextId( uint32 copy_id );

    //副本探索块总数
    uint32 GetChunkCount( uint32 copy_id );
    uint32 GetChunkCount( CCopyData::SData* copy );

    //获取指定区域存在的副本Id列表
    std::vector< uint32 >& GetAreaCopyList( uint32 area_id );

    //获取指定副本的boss列表
    std::vector< uint32 >& GetCopyBossList( uint32 copy_id );

private:
    std::map< uint32, std::vector< uint32 > > area_copy_list;
    std::map< uint32, std::vector< uint32 > > copy_boss_list;
};

#define theCopyExt TSignleton<CCopyExt>::Ref()
#endif
