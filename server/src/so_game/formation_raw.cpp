#include "raw.h"

#include "proto/formation.h"
#include "proto/constant.h"

RAW_USER_LOAD( formation_map )
{
    QuerySql( "select guid, attr, formation_type, formation_index from formation where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserFormation user_formation;
        user_formation.guid             = sql->getInteger( i++ );
        user_formation.attr             = sql->getInteger( i++ );
        user_formation.formation_type   = sql->getInteger( i++ );
        user_formation.formation_index  = sql->getInteger( i++ );
        data.formation_map[user_formation.formation_type].push_back( user_formation );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( formation_map )
{
    stream << strprintf( "delete from formation where role_id = %u;", guid ) << std::endl;

    if ( data.formation_map.empty() )
        return;
    for( std::map<uint32, std::vector<SUserFormation> >::iterator iter = data.formation_map.begin();
        iter != data.formation_map.end();
        ++iter )
    {
        if ( (iter->second).empty() )
            continue;

        stream << "insert into formation ( guid, role_id, attr, formation_type, formation_index ) values";

        int32 count = 0;
        for ( std::vector< SUserFormation >::iterator jter = (iter->second).begin();
            jter != (iter->second).end();
            ++jter )
        {
            if ( 0 != count )
                stream << ",";
            SUserFormation& formation = *jter;
            stream << "(" << formation.guid << ", " << guid << ", " << formation.attr << ", " <<  iter->first << ", " << formation.formation_index << ")";
            ++count;
        }
        stream << ";" << std::endl;;
    }
}
