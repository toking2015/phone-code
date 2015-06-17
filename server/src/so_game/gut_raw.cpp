#include "raw.h"

#include "proto/gut.h"

RAW_USER_LOAD( gut )
{
    QuerySql( "select gut_id, `index` from gut where role_id = %u", guid );
    if ( sql->empty() )
        return DB_SUCCEED;

    {
        int32 i = 0;

        data.gut.gut_id         = sql->getInteger(i++);
        data.gut.index          = sql->getInteger(i++);
    }

    QuerySql( "select `index`, event_type, event_tid, event_eid from gut_event where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        S3UInt32 s3;

        int32 index             = sql->getInteger(i++);
        s3.cate                 = sql->getInteger(i++);
        s3.objid                = sql->getInteger(i++);
        s3.val                  = sql->getInteger(i++);

        if ( index >= (int32)data.gut.event.size() )
            data.gut.event.resize( index + 1 );
        data.gut.event[ index ] = s3;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( gut )
{
    stream << strprintf( "delete from gut where role_id = %u;", guid ) << std::endl;
    stream << strprintf( "delete from gut_event where role_id = %u;", guid ) << std::endl;

    if ( data.gut.gut_id == 0 )
        return;

    stream << strprintf( "insert into gut( role_id, gut_id, `index` ) values( %u, %u, %d );",
        guid, data.gut.gut_id, data.gut.index ) << std::endl;

    if ( !data.gut.event.empty() )
    {
        stream << "insert into gut_event( role_id, `index`, event_type, event_tid, event_eid ) values";
        for ( int32 i = 0; i < (int32)data.gut.event.size(); ++i )
        {
            S3UInt32& s3 = data.gut.event[i];

            if ( i != 0 )
                stream << ", ";
            stream << "( " << guid << ", " << i << ", " << s3.cate << ", " << s3.objid << ", " << s3.val << " )";
        }
        stream << std::endl;
    }
}

