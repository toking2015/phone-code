#include "server.h"

#include "sql.h"
#include "misc.h"
#include "local.h"

#include "proto/constant.h"
#include "reportpost_imp.h"

namespace reportpost
{

    uint32 UpdateData( uint8 set_type, uint32 target_id, uint32 report_id, uint32 report_time )
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
        {
            LOG_ERROR("sql is null");
            return 1;
        }

        switch ( set_type )
        {
        case kObjectDel:
            {
                sql->execute( "delete from reportpost where target_id = %u", target_id );
            }
            break;
        case kObjectAdd:
            {
                sql->execute( "insert into reportpost values( %u, %u, %u )", target_id, report_id, report_time );
            }
            break;
        }

        return 0;
    }

    uint32 LoadData()
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
            return 1;

        PRReportPostInfoLoad rep;

        std::map<uint32,SReportPostInfo>::iterator iter = rep.info_map.end();

        SReportPostInfo data;
        uint32 target_id   = 0;
        uint32 report_id   = 0;
        uint32 report_time = 0;

        sql->query( "select target_id, report_id, report_time from reportpost order by target_id");
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            //加载元素
            target_id               = sql->getInteger(i++);
            report_id               = sql->getInteger(i++);
            report_time             = sql->getInteger(i++);

            iter = rep.info_map.find( target_id );

            if( iter != rep.info_map.end() )
            {

                iter->second.report_list.push_back( report_id );
            }
            else
            {
                if( rep.info_map.size() >= 512 )
                {
                    local::write( local::game, rep );

                    rep.info_map.clear();
                }

                data.target_id      = target_id;
                data.report_time    = report_time;
                data.report_list.clear();
                data.report_list.push_back( report_id );

                rep.info_map[target_id] = data;
            }

        }

        //发送剩余数据
        if ( !rep.info_map.empty() )
        {
            local::write( local::game, rep );

            rep.info_map.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );

        return 0;
    }
}

