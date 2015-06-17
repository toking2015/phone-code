#include "server.h"

#include "sql.h"
#include "misc.h"
#include "local.h"
#include "log.h"

#include "proto/constant.h"
#include "rank_imp.h"

namespace rank
{

    uint32 SaveRankCopy( uint8 rank_type, uint8 set_type, std::vector< SRankData >& list )
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
            return 1;

        switch ( set_type )
        {
        case kRankingObjectDel:
            {
                sql->execute( "delete from ranks where rank_type = %hhu", rank_type );
            }
            break;
        case kRankingObjectAdd:
            {

                wd::CStream bstr;
                for ( std::vector< SRankData >::iterator iter = list.begin();
                    iter != list.end();
                    ++iter )
                {
                    bstr.position(0);
                    uint32 uiSize = 0;
                    wd::CSeq::TFVarTypeProcess( iter->data, wd::CSeq::eWrite, bstr, uiSize );

                    sql->execute( "insert into ranks values( %hhu, %u, %u, %u, %u, '%s', %hu, '%s', %u, %u )",
                        rank_type,
                        iter->info.id, iter->info.limit, iter->info.first, iter->info.second,
                        sql->escape( &bstr[0], bstr.length() ).c_str(), iter->info.avatar, sql->escape( iter->info.name.c_str() ).c_str(), iter->info.team_level, iter->info.index );
                }
            }
            break;
        }

        return 0;
    }

    uint32 LoadRankCopy( uint8 rank_type )
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
            return 1;

        PRRankLoad rep;
        rep.rank_type = rank_type;
        rep.rank_attr = kRankAttrCopy;

        SRankData data;
        wd::CStream bstr;

        sql->query( "select guid, avatar, `name`, team_level, `index`, `limit`, first, second, data from ranks where rank_type = %hhu", rank_type );
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            //加载元素
            data.info.id            = sql->getInteger(i++);
            data.info.avatar        = sql->getInteger(i++);
            data.info.name          = sql->getString(i++);
            data.info.team_level    = sql->getInteger(i++);
            data.info.index         = sql->getInteger(i++);
            data.info.limit         = sql->getInteger(i++);
            data.info.first         = sql->getInteger(i++);
            data.info.second        = sql->getInteger(i++);

            //清空扩展数据
            data.data.clear();

            //加载二进制数据
            uint32 size = sql->getSize(i);
            if ( size > 0 )
            {
                if ( size > bstr.length() )
                    bstr.resize( size );

                sql->getData( i, &bstr[0], size );

                //反序列化
                bstr.position(0);
                uint32 uiSize = 0;
                wd::CSeq::TFVarTypeProcess( data.data, wd::CSeq::eRead, bstr, uiSize );
            }

            //压入列表
            rep.list.push_back( data );


            //发送数据
            if ( rep.list.size() >= 512 )
            {
                local::write( local::game, rep );

                rep.list.clear();
            }
        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );

        return 0;
    }

    int32 rank_parse_level_limit( uint32 level )
    {
        if ( level < 30 )
            return -1;

        return ( level / 10 ) * 10;
    }

    //竞技场
    void rank_real_load_singlearena( PRRankLoad& rep )
    {
        /**
        SRankData data;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select a.guid, a.avatar, a.name, a.team_level, b.rank from usersimple as a, singlearena as b where a.guid = b.target_id and a.team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.first         = sql->getInteger(i++);
                data.info.limit         = 10;

                rep.list.push_back( data );
                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }
        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        **/
        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //英雄
    void rank_real_load_soldier( PRRankLoad& rep )
    {
        SRankData data;
        std::vector< SRankData >  list;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select guid, avatar, name, team_level from usersimple where team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.limit         = 10;
                list.push_back( data );
            }

            for ( std::vector< SRankData >::iterator iter = list.begin();
                iter != list.end(); ++iter )
            {
                QuerySql( "select count(*), sum(star) from soldier where soldier_type = 1 and role_id = %u", ( *iter ).info.id );

                if ( !sql->empty() )
                {
                    int32 i = 0;
                    (*iter).info.first = sql->getInteger(i++);
                    (*iter).info.second = sql->getInteger(i++);
                }

                if( (*iter).info.first > 0 )
                    rep.list.push_back( *iter );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }

            list.clear();

        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //图腾
    void rank_real_load_totem( PRRankLoad& rep )
    {
        SRankData data;
        std::vector< SRankData >  list;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select guid, avatar, name, team_level from usersimple where team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.limit         = 10;
                list.push_back( data );
            }

            for ( std::vector< SRankData >::iterator iter = list.begin();
                iter != list.end(); ++iter )
            {
                QuerySql( "select count(*), sum(level) from totem where packet = 0 and role_id = %u", ( *iter ).info.id );

                if ( !sql->empty() )
                {
                    int32 i = 0;
                    (*iter).info.first = sql->getInteger(i++);
                    (*iter).info.second = sql->getInteger(i++);
                }


                if( (*iter).info.first > 0 )
                    rep.list.push_back( *iter );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }

            list.clear();

        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //副本
    void rank_real_load_copy( PRRankLoad& rep )
    {
        SRankData data;
        std::vector< SRankData >  list;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select a.guid, a.avatar, a.name, a.team_level, b.copy from usersimple as a, userstar as b where a.guid = b.guid and a.team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.first         = sql->getInteger(i++);
                data.info.limit         = 10;
                list.push_back( data );
            }

            for ( std::vector< SRankData >::iterator iter = list.begin();
                iter != list.end(); ++iter )
            {
                QuerySql( "select count(*) from copy_log where role_id = %u", ( *iter ).info.id );

                if ( !sql->empty() )
                {
                    int32 i = 0;
                    (*iter).info.second = sql->getInteger(i++);
                }

                if( (*iter).info.first > 0 )
                    rep.list.push_back( *iter );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }

            list.clear();

        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //拍卖行
    void rank_real_load_market( PRRankLoad& rep )
    {
        SRankData data;
        uint32 get_money    = 0;
        uint32 cost_money   = 0;
        uint32 limittime    = server::local_6_time( 0, 1);
        uint32 day_time     = 0;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select a.guid, a.avatar, a.name, a.team_level, b.market_day_get, b.market_day_cost, b.market_day_time from usersimple as a, userother as b where a.guid = b.guid and a.team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);

                data.info.limit         = 10;

                get_money    = sql->getInteger(i++);
                cost_money   = sql->getInteger(i++);
                day_time     = sql->getInteger(i++);

                if( day_time < limittime )
                {
                    data.info.first     = 0;
                    data.info.second   = 0;
                }
                else
                {
                    data.info.first     = get_money;//get_money > cost_money ? get_money - cost_money   : 0;
                    data.info.second    = 0;//cost_money > get_money ? cost_money - get_money   : 0;
                }



                if(  data.info.first > 0 )
                    rep.list.push_back( data );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }
        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //装备
    void rank_real_load_equip( PRRankLoad& rep )
    {
        SRankData data;
        std::vector< SRankData >  list;
        //uint32 max_count = 0;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select a.guid, a.avatar, a.name, a.team_level from usersimple as a where a.team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.limit         = 10;
                data.info.first         = 0;
                list.push_back( data );
            }

            for ( std::vector< SRankData >::iterator iter = list.begin();
                iter != list.end(); ++iter )
            {
                QuerySql( "select grade, equip_type,level  from equip_grade where role_id = %u and grade = ( select max(grade) from equip_grade where role_id = %u)", ( *iter ).info.id, (*iter).info.id );

                if ( !sql->empty() )
                {
                    int32 i = 0;
                    (*iter).info.first = sql->getInteger(i++);
                    (*iter).data["equip_type"] = sql->getInteger(i++);
                    (*iter).data["equip_level"] = sql->getInteger(i++);
                }

                if( (*iter).info.first > 0 )
                    rep.list.push_back( *iter );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }

            list.clear();
        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //战队等级
    void rank_real_load_teamlevel( PRRankLoad& rep )
    {
        SRankData data;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select a.guid, a.avatar, a.name, a.team_level, b.copy from usersimple as a, userstar as b where a.guid = b.guid and a.team_level >= 10" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.first         = data.info.team_level;
                data.info.second        = sql->getInteger(i++);
                data.info.limit         = 10;

                if( data.info.first > 0 )
                    rep.list.push_back( data );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }

        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }

    //神殿
    void rank_real_load_temple( PRRankLoad& rep )
    {
        SRankData data;
        for ( std::list< int32 >::iterator iter = server::id_list().begin();
            iter != server::id_list().end();
            ++iter )
        {
            wd::CSql* sql = sql::get( *iter );
            if ( sql == NULL )
                continue;

            QuerySql( "select a.guid,a.team_level,a.name,a.avatar, sum( b.score) from usersimple as a, temple_score as b where a.guid = b.role_id and a.team_level >= 10 and b.is_today = 1" );
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                int32 i = 0;
                data.info.id            = sql->getInteger(i++);
                data.info.avatar        = sql->getInteger(i++);
                data.info.name          = sql->getString(i++);
                data.info.team_level    = sql->getInteger(i++);
                data.info.first         = sql->getInteger(i++);
                data.info.second        = data.info.team_level;
                data.info.limit         = 10;

                if( data.info.first > 0 )
                    rep.list.push_back( data );

                if ( rep.list.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.list.clear();
                }
            }

        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );
    }



    uint32 LoadRankReal( uint8 rank_type )
    {
        PRRankLoad rep;
        rep.rank_type = rank_type;
        rep.rank_attr = kRankAttrReal;

        switch ( rank_type )
        {
        case kRankingTypeSingleArena:
            rank::rank_real_load_singlearena( rep );
            break;
        case kRankingTypeSoldier:
            rank::rank_real_load_soldier( rep );
            break;
        case kRankingTypeTotem:
            rank::rank_real_load_totem( rep );
            break;
        case kRankingTypeCopy:
            rank::rank_real_load_copy( rep );
            break;
        case kRankingTypeMarket:
            rank::rank_real_load_market( rep );
            break;
        case kRankingTypeEquip:
            rank::rank_real_load_equip( rep );
            break;
        case kRankingTypeTeamLevel:
            rank::rank_real_load_teamlevel( rep );
            break;
        case kRankingTypeTemple:
            rank::rank_real_load_temple( rep );
            break;
        }

        return 0;
    }

}// namespace rank

