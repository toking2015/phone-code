#include "raw.h"
#include "proto/temple.h"
#include "proto/constant.h"

RAW_USER_LOAD(temple)
{
    // 神殿
    QuerySql("select hole_cloth, hole_leather, hole_mail, hole_plate from temple where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        data.temple.hole_cloth   = sql->getInteger(i++);
        data.temple.hole_leather = sql->getInteger(i++);
        data.temple.hole_mail    = sql->getInteger(i++);
        data.temple.hole_plate   = sql->getInteger(i++);
    }

    // 组合
    QuerySql("select id, level from temple_group where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        STempleGroup g;
        g.id    = sql->getInteger(i++);
        g.level = sql->getInteger(i++);

        data.temple.group_list.push_back(g);
    }

    // 神符
    QuerySql("select guid, id, level, exp, embed_type, embed_index from temple_glyph where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        STempleGlyph g;
        g.guid        = sql->getInteger(i++);
        g.id          = sql->getInteger(i++);
        g.level       = sql->getInteger(i++);
        g.exp         = sql->getInteger(i++);
        g.embed_type  = sql->getInteger(i++);
        g.embed_index = sql->getInteger(i++);

        data.temple.glyph_list.push_back(g);
    }

    // 神殿积分
    QuerySql("select type, count, score from temple_score where role_id = %u and is_today = 0", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        uint32 type = sql->getInteger(i++);

        S2UInt32 s;
        s.first  = sql->getInteger(i++);
        s.second = sql->getInteger(i++);

        data.temple.score_yesterday[type] = s;
    }

    // 积分奖励
    QuerySql("select reward_id from temple_score_taken where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        uint32 id = sql->getInteger(i++);

        data.temple.score_taken_list.push_back(id);
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE(temple)
{
    stream << strprintf("delete from temple             where role_id = %u;", guid) << std::endl;
    stream << strprintf("delete from temple_group       where role_id = %u;", guid) << std::endl;
    stream << strprintf("delete from temple_glyph       where role_id = %u;", guid) << std::endl;
    stream << strprintf("delete from temple_score       where role_id = %u;", guid) << std::endl;
    stream << strprintf("delete from temple_score_taken where role_id = %u;", guid) << std::endl;

    // 神殿
    stream << strprintf("insert into temple(role_id, hole_cloth, hole_leather, hole_mail, hole_plate) values (%u, %u, %u, %u, %u);",
              guid, data.temple.hole_cloth, data.temple.hole_leather, data.temple.hole_mail, data.temple.hole_plate) << std::endl;

    // 组合
    for(std::vector<STempleGroup>::iterator iter = data.temple.group_list.begin(); iter != data.temple.group_list.end(); ++iter)
    {
        stream << strprintf("insert into temple_group(role_id, id, level) values(%u,%u,%u);", guid, iter->id, iter->level) << std::endl;
    }

    // 神符
    for(std::vector<STempleGlyph>::iterator iter = data.temple.glyph_list.begin(); iter != data.temple.glyph_list.end(); ++iter)
    {
        stream << strprintf("insert into temple_glyph(role_id, guid, id, level, exp, embed_type, embed_index) values(%u,%u,%u,%u,%u,%u,%u);",
                  guid, iter->guid, iter->id, iter->level, iter->exp, iter->embed_type, iter->embed_index) << std::endl;
    }

    // 神殿积分，今天的积分是便于做排行榜
    for(std::map<uint32, S2UInt32>::iterator iter = data.temple.score_yesterday.begin(); iter != data.temple.score_yesterday.end(); ++iter)
    {
        if(iter->second.first > 0)
        {
            stream << strprintf("insert into temple_score(role_id, is_today, type, count, score) values(%u,%u,%u,%u,%u);",
                guid, 0, iter->first, iter->second.first, iter->second.second) << std::endl;
        }
    }
    for(std::map<uint32, S2UInt32>::iterator iter = data.temple.score_current.begin(); iter != data.temple.score_current.end(); ++iter)
    {
        if(iter->second.first > 0)
        {
            stream << strprintf("insert into temple_score(role_id, is_today, type, count, score) values(%u,%u,%u,%u,%u);",
                guid, 1, iter->first, iter->second.first, iter->second.second) << std::endl;
        }
    }

    // 积分奖励
    for(std::vector<uint32>::iterator iter = data.temple.score_taken_list.begin(); iter != data.temple.score_taken_list.end(); ++iter)
    {
        stream << strprintf("insert into temple_score_taken(role_id, reward_id) values(%u,%u);", guid, *iter) << std::endl;
    }
}
