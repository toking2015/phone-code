#ifndef _COMMON_SQL_H_
#define _COMMON_SQL_H_

#include "common.h"
#include "weedong/core/sql/sql.h"

class sql
{
public:
    static wd::CSql* get( int32 id );
    static wd::CSql* get( std::string name );

private:
    static wd::CSql* allocate( std::string name );
};

#endif

