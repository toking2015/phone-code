#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_soldierextext.h"

uint32 CSoldierExtExt:: GetMaxLevel( std::vector< uint32 > &list )
{
    uint32 level = 0;
    for( std::vector< uint32 >::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
       SData* data = Find( *iter );
       if ( data )
       {
           level = level < data->level ? data->level : level;
       }
    }

    return level;
}

uint32 CSoldierExtExt:: GetSumFighting( std::vector< uint32 > &list )
{
    uint32 fighting = 0;
    for( std::vector< uint32 >::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
       SData* data = Find( *iter );
       if ( data )
       {
           fighting += data->fighting;
       }
    }

    return fighting;
}

