#include "raw.h"

#include "proto/building.h"
#include "proto/constant.h"

RAW_USER_LOAD( building_list )
{
    QuerySql( "select role_id, info_id, info_type, info_level, position_x, position_y, production, time_point from building where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserBuilding user_building;
        user_building.data.target_id                 = sql->getInteger( i++ );
        user_building.data.info_id                   = sql->getInteger( i++ );
        user_building.data.info_type                 = sql->getInteger( i++ );
        user_building.data.info_level                = sql->getInteger( i++ );
        user_building.data.info_position.first       = sql->getInteger( i++ );
        user_building.data.info_position.second      = sql->getInteger( i++ );

        user_building.ext.production                 = sql->getInteger( i++ );
        user_building.ext.time_point                 = sql->getInteger( i++ );

        //初始化type && guid
        user_building.building_type = user_building.data.info_type;
        user_building.building_guid = user_building.data.info_id;

        data.building_list.push_back( user_building );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( building_list )
{
    stream << strprintf( "delete from building where role_id = %u;", guid ) << std::endl;

    stream << "insert into building ( role_id, info_id, info_type, info_level, position_x, position_y, production, time_point ) values";
    int32 count = 0;
    for( std::vector< SUserBuilding >::iterator iter = data.building_list.begin();
        iter != data.building_list.end();
        ++iter )
    {
            if ( 0 != count )
                stream << ",";
            SUserBuilding& building = *iter;
            stream << "(" << building.data.target_id << ", " << building.data.info_id << ", " << (uint16)building.data.info_type << ", " << building.data.info_level << ", " << building.data.info_position.first << ", " << building.data.info_position.second << ", " << building.ext.production << ", " << building.ext.time_point;
            stream <<")";
            ++count;
    }
    stream << ";" << std::endl;
}

