#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_copyext.h"

uint32 CCopyExt::GetFrontId( uint32 copy_id )
{
    std::map< uint32, CCopyData::SData* >::iterator iter = id_copy_map.find( copy_id );
    if ( iter == id_copy_map.end() || iter == id_copy_map.begin() )
        return 0;

    return (--iter)->first;
}
uint32 CCopyExt::GetNextId( uint32 copy_id )
{
    std::map< uint32, CCopyData::SData* >::iterator iter = id_copy_map.find( copy_id );
    if ( iter == id_copy_map.end() )
        return 0;

    if ( ++iter == id_copy_map.end() )
        return 0;

    return iter->first;
}

uint32 CCopyExt::GetChunkCount( CCopyData::SData* copy )
{
    uint32 count = 0;
    for ( ; count < copy->chunk.size(); ++count )
    {
        if ( copy->chunk[ count ].cate == 0 )
            break;
    }

    return count;
}

uint32 CCopyExt::GetChunkCount( uint32 copy_id )
{
    CCopyData::SData* copy = Find( copy_id );
    if ( copy == NULL )
        return 0;

    return GetChunkCount( copy );
}

std::vector< uint32 >& CCopyExt::GetAreaCopyList( uint32 area_id )
{
    return area_copy_list[ area_id ];
}

std::vector< uint32 >& CCopyExt::GetCopyBossList( uint32 copy_id )
{
    return copy_boss_list[ copy_id ];
}

void CCopyExt::LoadData(void)
{
    CCopyData::LoadData();

    for ( std::map<uint32, SData*>::iterator i = id_copy_map.begin();
        i != id_copy_map.end();
        ++i )
    {
        area_copy_list[ i->first / 1000 ].push_back( i->first );

        for ( std::vector<S3UInt32>::iterator j = i->second->boss_chunk.begin();
            j != i->second->boss_chunk.end();
            ++j )
        {
            //cate == 6 简单战斗副本 boss
            //cate == 7 迎敌战为 boss
            if ( j->cate == 6 || j->cate == 7 )
            {
                copy_boss_list[ i->first ].push_back( j->objid );
            }
        }
    }
}
void CCopyExt::ClearData(void)
{
    copy_boss_list.clear();
    area_copy_list.clear();

    CCopyData::ClearData();
}

