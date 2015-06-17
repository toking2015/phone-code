#include "raw.h"
#include "proto/paper.h"

RAW_USER_LOAD(copy_material_list)
{
    QuerySql("select collect_level, left_collect_times, del_timestamp from copy_material where role_id = %u", guid);
    for (sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        SUserCopyMaterial obj;
        obj.collect_level = sql->getInteger(i++);
        obj.left_collect_times = sql->getInteger(i++);
        obj.del_timestamp = sql->getInteger(i++);
        data.copy_material_list.push_back(obj);
    }
    return DB_SUCCEED;
}

RAW_USER_SAVE(copy_material_list)
{
    stream << strprintf("delete from copy_material where role_id = %u;", guid) << std::endl;
    if (data.copy_material_list.empty())
        return;

    stream << "insert into copy_material (role_id, collect_level, left_collect_times, del_timestamp) values";
    for (std::vector<SUserCopyMaterial>::iterator iter = data.copy_material_list.begin();
        iter != data.copy_material_list.end();
        ++iter)
    {
        if (iter != data.copy_material_list.begin())
            stream << ", ";
        stream << "(" << guid << ", " << iter->collect_level << ", " << iter->left_collect_times << ", " << iter->del_timestamp << ")";
    }
    stream << std::endl;
}
