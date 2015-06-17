#include "raw.h"

RAW_USER_LOAD(equip_suit_level)
{
    QuerySql("select equip_type1, equip_type2, equip_type3, equip_type4 from equip_suit_level where role_id = %u", guid);
    if (!sql->empty())
    {
        for (uint32 i = 0; i < 4; i++)
            data.equip_suit_level.push_back(sql->getInteger(i));
    }
    data.equip_suit_level.resize(4);
    for (std::vector<uint32>::iterator iter = data.equip_suit_level.begin();
        iter != data.equip_suit_level.end();
        ++iter)
    {
        if (*iter == 0)
            *iter = 1;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE(equip_suit_level)
{
    stream << strprintf("delete from equip_suit_level where role_id = %u;", guid) << std::endl;
    if (data.equip_suit_level.empty())
        return;

    stream << "insert into equip_suit_level (role_id, equip_type1, equip_type2, equip_type3, equip_type4) values(" << guid;
    data.equip_suit_level.resize(4);
    for (uint32 i = 0; i < 4; i++)
    {
        stream << "," << data.equip_suit_level[i];
    }
    stream << ")" << std::endl;
}

RAW_USER_LOAD(equip_grade_list)
{
    QuerySql("select equip_type, level, grade from equip_grade where role_id = %u", guid);
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserEquipGrade obj;
        obj.equip_type = sql->getInteger(i++);
        obj.level = sql->getInteger(i++);
        obj.grade = sql->getInteger(i++);
        data.equip_grade_list.push_back(obj);
    }
    return DB_SUCCEED;
}

RAW_USER_SAVE(equip_grade_list)
{
    stream << strprintf("delete from equip_grade where role_id = %u;", guid) << std::endl;
    if (data.equip_grade_list.empty())
        return;

    stream << "insert into equip_grade (role_id, equip_type, level, grade) values";
    for (std::vector<SUserEquipGrade>::iterator iter = data.equip_grade_list.begin();
        iter != data.equip_grade_list.end();
        ++iter)
    {
        if (iter != data.equip_grade_list.begin())
            stream << ",";
        stream << "(" << guid << "," << iter->equip_type << "," << iter->level << "," << iter->grade << ")";
    }
    stream << std::endl;
}
