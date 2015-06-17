#include "raw.h"
#include "msg.h"
#include "db.h"

#include "proto/system.h"

SO_LOAD( raw_interface_register )
{
    theDB.bind( CDB::db::user, raw::load_to_msg< SUserData, PRSystemUserLoad >, raw::save_to_db );
    theDB.bind( CDB::db::guild, raw::load_to_msg< SGuildData, PRSystemGuildLoad >, raw::save_to_db );
}

int32 raw::save_to_db( uint32 guid, std::string& sql_string )
{
    int32 ret = 0;
    int32 sid = SERVER_ID( guid );

    wd::CSql* sql = sql::get( SERVER_ID( guid ) );
    if ( sql == NULL )
    {
        LOG_ERROR( "raw::save_to_db error: sid[%d], guid[%u]", sid, guid );
        return -1;
    }

    //事务开始
    if ( !sql->execute( "start transaction" ) && sql->lastErrorCode() != 0 )
    {
        LOG_ERROR( "sql start transaction error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), sql_string.c_str() );
        return -1;
    }

    //以换行标识分割执行
    char *beg = (char*)sql_string.c_str();
    for ( char* cur = beg; *cur != '\0'; ++cur )
    {
        if ( *cur == '\n' )
        {
            *cur = '\0';

            if ( !sql->execute( "%s", beg ) && sql->lastErrorCode() != 0 )
            {
                LOG_ERROR( "sql execute error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), beg );

                //回滚数据
                sql->execute( "roolback" );
                return -1;
            }

            //重置下一行执行语句起始位置
            beg = cur + 1;
        }
    }

    //提交数据
    if ( !sql->execute( "commit" ) && sql->lastErrorCode() != 0 )
    {
        LOG_ERROR( "sql start commit error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), sql_string.c_str() );
        return -1;
    }

    return ret;
}

