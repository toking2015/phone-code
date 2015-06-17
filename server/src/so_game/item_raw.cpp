#include "raw.h"

#include "proto/item.h"
#include "proto/constant.h"

RAW_USER_LOAD( item_map )
{
    QuerySql( "select guid, bag_type, item_id, due_time, count, item_index, flags, soldier_guid, main_attr_factor, slave_attr_factor, slave_attr0, slave_attr1, slave_attr2, slave_attr3, slave_attr4, slave_attr5, slotattr0, slotvalue0, slotattr1, slotvalue1, slotattr2, slotvalue2 from item where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserItem user_item;
        user_item.guid       = sql->getInteger( i++ );
        user_item.bag_type   = sql->getInteger( i++ );
        user_item.item_id    = sql->getInteger( i++ );
        user_item.due_time   = sql->getInteger( i++ );
        user_item.count      = sql->getInteger( i++ );
        user_item.item_index = sql->getInteger( i++ );
        user_item.flags      = sql->getInteger( i++ );
        user_item.soldier_guid   = sql->getInteger( i++ );
        user_item.main_attr_factor = sql->getInteger( i++ );
        user_item.slave_attr_factor = sql->getInteger( i++ );
        for( uint32 j = 0; j < kItemRandMax; ++j )
        {
            uint32 temp = sql->getInteger( i++ );
            user_item.slave_attrs.push_back(temp);
        }
        for( uint32 j = 0; j < kItemSlotMax; ++j )
        {
            S2UInt16 temp_attr;
            temp_attr.first     = sql->getInteger( i++ );
            temp_attr.second    = sql->getInteger( i++ );
            user_item.slotattr.push_back( temp_attr );
        }
        data.item_map[user_item.bag_type].push_back( user_item );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( item_map )
{
    stream << strprintf( "delete from item where role_id = %u;", guid ) << std::endl;

    if ( data.item_map.empty() )
        return;
    for( std::map<uint32, std::vector<SUserItem> >::iterator iter = data.item_map.begin();
        iter != data.item_map.end();
        ++iter )
    {

        if ( (iter->second).empty() )
            continue;

        stream << "insert into item (guid, role_id, bag_type, item_id, due_time, count, item_index, flags, soldier_guid, main_attr_factor, slave_attr_factor, slave_attr0, slave_attr1, slave_attr2, slave_attr3, slave_attr4, slave_attr5, slotattr0, slotvalue0, slotattr1, slotvalue1, slotattr2, slotvalue2 ) values";

        int32 count = 0;
        for ( std::vector< SUserItem >::iterator jter = (iter->second).begin();
            jter != (iter->second).end();
            ++jter )
        {
            if ( 0 != count )
                stream << ",";
            SUserItem& item = *jter;
            stream << "(" << item.guid << ", " << guid << ", " << (uint16)item.bag_type << ", " << item.item_id << ", " << item.due_time << ", " << item.count << ", " << item.item_index << ", " << (uint16)item.flags << ", " << item.soldier_guid << ", " << item.main_attr_factor << ", " << item.slave_attr_factor;
            for (uint32 i = 0; i < kItemRandMax; ++i)
            {
                if ( i >= item.slave_attrs.size() )
                    stream << ",0";
                else
                    stream << "," << item.slave_attrs[i];
            }
            for (uint32 i = 0; i < kItemSlotMax; ++i)
            {
                if ( i >= item.slotattr.size() )
                    stream << ",0,0";
                else
                    stream << "," << item.slotattr[i].first << "," << item.slotattr[i].second;
            }
            stream <<")";
            ++count;
        }
        stream << ";" << std::endl;
    }
}
