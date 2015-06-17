#ifndef _GAMESVR_GUILD_DC_H_
#define _GAMESVR_GUILD_DC_H_

#include "common.h"
#include "proto/guild.h"

#include "dc.h"

class CGuildDC : public TDC< CGuildMap >
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
    CGuildDC() : TDC< CGuildMap >( "guild" )
    {
    }

    ~CGuildDC()
    {
    }

    SGuildSimple* find_simple( uint32 id );

    SGuild* find( uint32 id );
    SGuild* create( uint32 id, SGuildData& data );

    //根据 db.save_index, 保存一个公会数据
    void save_once(uint32 count);

public:
    void query_save( uint32 id );

    //create == true 为自动创建新公会
    void query_load( uint32 id, bool create );

    //释放一个数据对象
    void release( uint32 id );

    //释放超时数据对象
    void release_timeout_guild( uint32 seconds );

    //释放超时异步协议
    void release_timeout_defer( uint32 seconds );

    //id,name 查找
    std::string find_name( uint32 id );
    uint32 find_id( std::string name );

    //请求公会列表
    uint32 query_list( uint32 index, uint32 count, std::vector< uint32 >& list );

    //排序军团数据
    void sort(void);

private:
    void save( SGuild& guild );

    std::vector< uint32 > create_base_id_array(void);

public:
    void defer_msg( uint32 id, int32 sock, int32 key, wd::CStream* stream );
    void dispatch_defer( uint32 id );

public:
    static bool guild_compare_member_count( uint32 l_id, uint32 r_id );
};
#define theGuildDC TSignleton< CGuildDC >::Ref()

#define QG( n, id )\
    if ( id == 0 )\
        return;\
    SGuild* n = theGuildDC.find( id );\
    if ( n == NULL )\
    {\
        wd::CStream* stream = new wd::CStream();\
        *stream << msg;\
        theGuildDC.query_load( id, false );\
        theGuildDC.defer_msg( id, sock, key, stream );\
        return;\
    }

#endif

