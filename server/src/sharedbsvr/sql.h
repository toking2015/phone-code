#ifndef _COMMON_SQL_H_
#define _COMMON_SQL_H_

#include "common.h"
#include "log.h"
#include <weedong/core/sql/sql.h>

class sql
{
public:
    static wd::CSql* get( int32 id );
    static wd::CSql* get( std::string name );

private:
    static wd::CSql* allocate( std::string name );
};

#define QuerySql(fmt, ...)\
    if (!sql->query(fmt, ##__VA_ARGS__) && 0 != sql->lastErrorCode())\
    {\
        LOG_ERROR("sql query error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), sql->lastSqlString());\
        return;\
    }

#define ExecuteSql(fmt, ...)\
    if (!sql->execute(fmt, ##__VA_ARGS__) && 0 != sql->lastErrorCode())\
    {\
        LOG_ERROR("sql execute error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), sql->lastSqlString());\
        return;\
    }

#endif

