#ifndef _GAMESVR_RAW_H_
#define _GAMESVR_RAW_H_

#include <weedong/core/sql/sql.h>

#include "common.h"
#include "db.h"
#include "log.h"
#include "misc.h"
#include "util.h"
#include "sql.h"
#include "netsingle.h"
#include "local.h"

#include "proto/constant.h"
#include "proto/common.h"
#include "proto/user.h"
#include "proto/guild.h"

class raw
{
public:
    template< typename T >
    static std::map< std::string, T >& raw_map(void)
    {
        static std::map< std::string, T > map;
        return map;
    }

public:
    template< typename T >
    static void* _reg( std::string name, T call )
    {
        raw_map< T >()[ name ] = call;
        return NULL;
    }

public:
    //读取 guid 用户数据并返回 PRSystemUserLoad 数据流, create == true 为自动创建新角色
    template< typename T >
    struct load_to_msg_progress
    {
        int32& ret;
        uint32 guid;
        T& data;
        load_to_msg_progress( int32& r, uint32 id, T& d ) : ret(r), guid(id), data(d){}

        template< typename E >
        void operator()( E& ele )
        {
            //如果出现错误不再尝试读取数据库
            if ( ret != DB_SUCCEED )
                return;

            wd::CSql* sql = sql::get( SERVER_ID( guid ) );
            if ( sql == NULL )
            {
                ret = DB_INVALID;
                return;
            }

            ret = ele.second( guid, data, sql );
        }
    };
    template< typename T, typename P >
    static int32 load_to_msg( uint32 guid, bool create )
    {
        typedef int32(*TCallLoad)( uint32, T&, wd::CSql* );

        int32 ret = DB_SUCCEED;

        P msg;
        msg.guid = guid;

        std::for_each
        (
            raw_map< TCallLoad >().begin(),
            raw_map< TCallLoad >().end(),
            load_to_msg_progress< T >( ret, guid, msg.data )
        );

        //数据加载异常
        switch ( ret )
        {
        case DB_SUCCEED:
            {
                //加载成功后直接发送数据
                local::post( local::self, msg );

                LOG_INFO( "load_to_msg: load guid[%u] succeed!", guid );
            }
            break;

        case DB_INVALID:
            {
                LOG_INFO( "load_to_msg: load guid[%u] invalid!", guid );
            }
            break;

        case DB_SQL_SYNTAX:
            {
                LOG_ERROR( "load_to_msg: load guid[%u] sql syntax!", guid );
            }
            break;

        case DB_NOT_EXIST:
            {
                if ( create )
                {
                    //创建新用户, 直接发送数据
                    msg.created = kYes;
                    local::post( local::self, msg );

                    LOG_INFO( "load_to_msg: create guid[%u] finished!", guid );
                }
                else
                    LOG_INFO( "load_to_msg: guid[%u] not found!", guid );
            }
            break;

        default:
            {
                LOG_ERROR( "load_to_msg: load guid[%u] error", guid );
            }
            break;
        }

        //错误不发送数据
        return ret;
    }

    //取得数据存储 sql 字符串集合
    template< typename T >
    struct get_save_string_progress
    {
        typedef S4Int32(*TCallMd5)( T& );

        uint32 guid;
        T& data;
        std::map< std::string, S4Int32 >& check;
        std::stringstream& stream;

        get_save_string_progress
        (
            uint32 id,
            T& d,
            std::map< std::string, S4Int32 >& c,
            std::stringstream& s
        ) : guid(id), data(d), check(c), stream(s){}

        template< typename E >
        void operator()( E& ele )
        {
             //获取模块数据 md5
            S4Int32 md5_var = raw_map< TCallMd5 >()[ ele.first ]( data );

            S4Int32& cur_var = check[ ele.first ];
            if ( cur_var.v1 != md5_var.v1 || cur_var.v2 != md5_var.v2 || cur_var.v3 != md5_var.v3 || cur_var.v4 != md5_var.v4 )
            {
                //获取保存字符串记录
                ele.second( guid, data, stream );

                //保存最新 md5 值
                cur_var = md5_var;
            }
        }
    };
    template< typename T >
    static std::string get_save_string( uint32 guid, T& data, std::map< std::string, S4Int32 >& check )
    {
        typedef void(*TCallSave)( uint32, T&, std::stringstream& );
        typedef S4Int32(*TCallMd5)( T& );

        std::stringstream stream;

        //遍历所有保存接口
        std::for_each
        (
            raw_map< TCallSave >().begin(),
            raw_map< TCallSave >().end(),
            get_save_string_progress< T >( guid, data, check, stream )
        );

        return stream.str();
    }

    //初始化 md5 值
    template< typename T >
    struct init_md5_progress
    {
        T& data;
        std::map< std::string, S4Int32 >& check;
        init_md5_progress( T& d, std::map< std::string, S4Int32 >& c ) : data(d), check(c){}

        template< typename E >
        void operator()( E& ele )
        {
            //获取模块数据 md5
            check[ ele.first ] = ele.second( data );
        }
    };
    template< typename T >
    static void init_md5( T& data, std::map< std::string, S4Int32 >& check )
    {
        typedef S4Int32(*TCallMd5)( T& );

        std::for_each( raw_map< TCallMd5 >().begin(), raw_map< TCallMd5 >().end(), init_md5_progress< T >( data, check ) );
    }

    //保存数据到 db
    static int32 save_to_db( uint32 guid, std::string& sql_string );
};
#define theRaw TSignleton< raw >::Ref()

//====================SUserData==================
#define RAW_USER_LOAD( element )\
    int32 _raw_user_load_##element( uint32 guid, SUserData& data, wd::CSql* sql );\
    void* _raw_user_load_reg_ptr_##element = raw::_reg( #element, _raw_user_load_##element );\
    int32 _raw_user_load_##element( uint32 guid, SUserData& data, wd::CSql* sql )

#define RAW_USER_SAVE( element )\
    S4Int32 _raw_user_get_md5_##element( SUserData& data );\
    void* _raw_user_get_md5_reg_ptr_##element = raw::_reg( #element, _raw_user_get_md5_##element );\
    S4Int32 _raw_user_get_md5_##element( SUserData& data )\
    {\
        wd::CStream stream;\
        stream << data.element;\
        SMd5Value m5v = md5_value( (uint8*)&stream[0], stream.length() );\
        S4Int32 u4;\
        u4.v1 = m5v.values[0];\
        u4.v2 = m5v.values[1];\
        u4.v3 = m5v.values[2];\
        u4.v4 = m5v.values[3];\
        return u4;\
    }\
    void _raw_user_save_##element( uint32 guid, SUserData& data, std::stringstream& stream );\
    void* _raw_user_save_reg_ptr_##element = raw::_reg( #element, _raw_user_save_##element );\
    void _raw_user_save_##element( uint32 guid, SUserData& data, std::stringstream& stream )

//==================SGuildData===================
#define RAW_GUILD_LOAD( element )\
    int32 _raw_guild_load_##element( uint32 guid, SGuildData& data, wd::CSql* sql );\
    void* _raw_guild_load_reg_ptr_##element = raw::_reg( #element, _raw_guild_load_##element );\
    int32 _raw_guild_load_##element( uint32 guid, SGuildData& data, wd::CSql* sql )

#define RAW_GUILD_SAVE( element )\
    S4Int32 _raw_guild_get_md5_##element( SGuildData& data );\
    void* _raw_guild_get_md5_reg_ptr_##element = raw::_reg( #element, _raw_guild_get_md5_##element );\
    S4Int32 _raw_guild_get_md5_##element( SGuildData& data )\
    {\
        wd::CStream stream;\
        stream << data.element;\
        SMd5Value m5v = md5_value( (uint8*)&stream[0], stream.length() );\
        S4Int32 u4;\
        u4.v1 = m5v.values[0];\
        u4.v2 = m5v.values[1];\
        u4.v3 = m5v.values[2];\
        u4.v4 = m5v.values[3];\
        return u4;\
    }\
    void _raw_guild_save_##element( uint32 guid, SGuildData& data, std::stringstream& stream );\
    void* _raw_guild_save_reg_ptr_##element = raw::_reg( #element, _raw_guild_save_##element );\
    void _raw_guild_save_##element( uint32 guid, SGuildData& data, std::stringstream& stream )

//===================SQL================
#define QuerySql(fmt, ...)\
    if (!sql->query(fmt, ##__VA_ARGS__) && 0 != sql->lastErrorCode())\
    {\
        LOG_ERROR("sql query error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), sql->lastSqlString());\
        return DB_SQL_SYNTAX;\
    }

#define ExecuteSql(fmt, ...)\
    if (!sql->execute(fmt, ##__VA_ARGS__) && 0 != sql->lastErrorCode())\
    {\
        LOG_ERROR("sql execute error[%d][%s][%s]", sql->lastErrorCode(), sql->lastErrorMsg(), sql->lastSqlString());\
        return DB_SQL_SYNTAX;\
    }

#endif

