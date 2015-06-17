#ifndef _GAMESVR_USER_DC_H_
#define _GAMESVR_USER_DC_H_

#include "common.h"
#include "proto/user.h"

#include "dc.h"

class CUserDC : public TDC< CUserMap >
{
public:
    struct SDefer
    {
        int32 sock;
        int32 key;
        uint32 time;
        wd::CStream* stream;

        SDefer() : sock(0), key(0), stream(NULL)
        {
            time = (uint32)::time(NULL);
        }

        SDefer( int32 s, int32 k, wd::CStream* str ) : sock(s), key(k), stream(str)
        {
            time = (uint32)::time(NULL);
        }
    };
private:
    std::map< uint32, std::list< SDefer > > defer_map;

public:
    CUserDC() : TDC< CUserMap >( "user" )
    {
    }

    ~CUserDC()
    {
    }

    SUser* find( uint32 id );
    SUser* create( uint32 id, SUserData& data );

    //少量保存一次数据
    void save_once( uint32 count );

    //保存指定时间内未保存过的用户
    void each_save( uint32 seconds );

public:
    void query_save( uint32 id );

    //create == true 为自动创建新用户
    void query_load( uint32 id, bool create );

    //释放一个数据对象
    void release( uint32 id );

    //释放超时数据对象
    void release_timeout_user( uint32 seconds );

    //释放超时异步协议
    void release_timeout_defer( uint32 seconds );

    //id,name 查找
    std::string find_name( uint32 id );
    uint32 find_id( std::string name );

    //强制下线
    void quit_force( uint32 id, uint32 err_no );

private:
    //有数据需要保存时返回 true
    bool save( SUser& user );

public:
    //基于基本文件的用户数据存储备份系统
    void save_file( uint32 rid, SUserData& data );
    bool load_file( uint32 rid, SUserData& data );

    void defer_msg( uint32 id, int32 sock, int32 key, wd::CStream* stream );
    void dispatch_defer( uint32 id );

public:
    uint32 Recommend();
};
#define theUserDC TSignleton< CUserDC >::Ref()

//仅限用于在线用户请求
#define QU_ON( n, id )\
    if ( id == 0 )\
        return;\
    SUser* n = theUserDC.find( id );\
    if ( n == NULL )\
        return;

//仅限用于离线用户请求
#define QU_OFF( n, id )\
    if ( id == 0 )\
        return;\
    SUser* n = theUserDC.find( id );\
    if ( n == NULL )\
    {\
        wd::CStream* stream = new wd::CStream();\
        *stream << msg;\
        theUserDC.query_load( id, false );\
        theUserDC.defer_msg( id, sock, key, stream );\
        return;\
    }

#endif

