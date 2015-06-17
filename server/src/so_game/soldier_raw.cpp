#include "raw.h"

#include "proto/soldier.h"
#include "proto/constant.h"

RAW_USER_LOAD( soldier_map )
{
    QuerySql( "select guid, soldier_id, soldier_type, soldier_index, level, xp, quality, quality_lv, quality_xp, star, hp, mp from soldier where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserSoldier user_soldier;
        user_soldier.guid               = sql->getInteger( i++ );
        user_soldier.soldier_id         = sql->getInteger( i++ );
        user_soldier.soldier_type       = sql->getInteger( i++ );
        user_soldier.soldier_index      = sql->getInteger( i++ );
        user_soldier.level              = sql->getInteger( i++ );
        user_soldier.xp                 = sql->getInteger( i++ );
        user_soldier.quality            = sql->getInteger( i++ );
        user_soldier.quality_lv         = sql->getInteger( i++ );
        user_soldier.quality_xp         = sql->getInteger( i++ );
        user_soldier.star               = sql->getInteger( i++ );
        user_soldier.hp                 = sql->getInteger( i++ );
        user_soldier.mp                 = sql->getInteger( i++ );

        data.soldier_map[ user_soldier.soldier_type ][ user_soldier.guid ] = user_soldier;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( soldier_map )
{
    stream << strprintf( "delete from soldier where role_id = %u;", guid ) << std::endl;

    if( data.soldier_map.empty() )
        return;
    for( std::map< uint32, std::map< uint32, SUserSoldier > >::iterator iter = data.soldier_map.begin();
        iter != data.soldier_map.end();
        ++iter )
    {
        if ( (iter->second).empty() )
            continue;

        stream << "insert into soldier ( guid, role_id, soldier_id, soldier_type, soldier_index, level, xp, quality, quality_lv, quality_xp, star, hp, mp ) values";

        int32 count = 0;
        for ( std::map< uint32, SUserSoldier >::iterator jter = (iter->second).begin();
            jter != (iter->second).end();
            ++jter )
        {
            if ( 0 != count )
                stream << ",";
            SUserSoldier& soldier = jter->second;
            stream << "(" << soldier.guid << ", " << guid << ", " << soldier.soldier_id << ", " << iter->first << ", " << soldier.soldier_index << ", " << soldier.level << ", " << soldier.xp << ", " << soldier.quality << ", " << soldier.quality_lv <<  ", " << soldier.quality_xp << ", " << soldier.star << ", " << soldier.hp << ", " << soldier.mp <<  ")";
            ++count;
        }
        stream << ";" << std::endl;
    }
}
