#ifndef _GAMESVR_DB_H_
#define _GAMESVR_DB_H_

#include "common.h"

const int32 DB_SUCCEED          = 0;        //正常处理
const int32 DB_INVALID          = 1;        //无效的SQL对象
const int32 DB_SQL_SYNTAX       = 2;        //执行语法错误
const int32 DB_NOT_EXIST        = 3;        //用户不存在

class CDB : public wd::CThread
{
public:
    typedef int32 (*FCallLoad)( uint32 id, bool create );
    typedef int32 (*FCallSave)( uint32 id, std::string& sql_string );

    struct db
    {
        enum type
        {
            user    = 1,        //用户数据
            guild   = 2,        //公会数据
        };
    };

    enum
    {
        EStop = 1,
    };
private:
    wd::CMutex mutex;

    //< type, < id, create > >
    std::map< int32, std::list< std::pair< uint32, bool > > > load_list_map;

    //< type, < id, sql_string > >
    std::map< int32, std::list< std::pair< uint32, std::string > > > save_list_map;

    //< id, < load, save > >
    std::map< uint32, std::pair< FCallLoad, FCallSave > > call_map;

    uint32 thread_status;

public:
    wd::CMutex reload_mutex;

public:
    CDB();

    uint32 Run(void);
    void EndThread(void);

    void bind( CDB::db::type type, FCallLoad load, FCallSave save );

    //create == true 为自动创建新用户
    void post_load( CDB::db::type type, uint32 id, bool create );
    void post_save( CDB::db::type type, uint32 id, std::string& sql_string );

private:
    bool do_load_event(void);
    bool do_save_event(void);
};
#define theDB TSignleton< CDB >::Ref()

#endif

