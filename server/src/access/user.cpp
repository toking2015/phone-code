#include "user.h"
#include "netio.h"
#include "msg.h"

#define BUFFER_MAX 32

namespace user
{

SData* last_find_user = NULL;

std::map< uint32, SData >& data_map(void)
{
    static std::map< uint32, SData > map;
    return map;
}
std::map< int32, uint32 >& sock_map(void)
{
    static std::map< int32, uint32 > map;
    return map;
}
SData* find( uint32 role_id )
{
    if ( last_find_user != NULL && last_find_user->role_id == role_id )
        return last_find_user;

    std::map< uint32, SData >::iterator iter = data_map().find( role_id );
    if ( iter == data_map().end() )
        return NULL;

    last_find_user = &( iter->second );

    return last_find_user;
}

void delete_session( uint32 role_id )
{
    if ( last_find_user != NULL && last_find_user->role_id == role_id )
        last_find_user = NULL;

    data_map().erase( role_id );
}

SData* update_session( uint32 role_id, uint32 session )
{
    SData& user = data_map()[ role_id ];

    user.role_id = role_id;
    user.session = session;

    return (&user);
}

bool check_session( uint32 role_id, uint32 session )
{
    if ( session == 0 )
        return false;

    SData* data = find( role_id );
    if ( data == NULL )
        return false;

    return ( data->session == session );
}

void reset_order( uint32 role_id )
{
    SData* data = find( role_id );
    if ( data != NULL )
    {
        data->server_order = 1;
        data->client_order = 1;

        data->client_buff_map.clear();
        data->server_buff_map.clear();
    }
}

uint32 pack_order_process( uint32 role_id, uint32 client_order )
{
    SData* data = find( role_id );
    if ( data == NULL )
        return 0;

    if ( client_order != data->client_order )
        return data->client_order;

    //累加 order 值
    data->client_order++;

    //将堆积的数据包重新处理
    std::map< uint32, SData::SBuff >::iterator iter = data->client_buff_map.find( data->client_order );
    if ( iter != data->client_buff_map.end() )
    {
        SData::SBuff& buff = iter->second;

        theMsg.Post( buff.sock, buff.key, &buff.stream[0], buff.stream.length() );

        data->client_buff_map.erase( iter );
    }

    return client_order;
}

void pack_order_push( uint32 role_id, uint32 client_order, int32 sock, int32 key, wd::CStream& stream )
{
    SData* data = find( role_id );
    if ( data == NULL )
        return;

    //小于 order 不受理, 可能是重复数据包
    if ( client_order < data->client_order )
        return;

    //可能是恶意堆包, 移除用户信息
    if ( data->client_buff_map.size() > BUFFER_MAX )
    {
        delete_session( role_id );
        return;
    }

    SData::SBuff& buff = data->client_buff_map[ client_order ];
    buff.sock = sock;
    buff.key = key;
    buff.stream.write( &stream[0], stream.length() );
}

void write( uint32 role_id, uint32 server_order, void* data, uint32 size )
{
    SData* user_data = find( role_id );
    if ( user_data == NULL )
        return;

    //order == 0 的数据包不作缓存处理
    if ( server_order != 0 )
    {
        wd::CStream& stream = user_data->server_buff_map[ server_order ];
        stream.write( data, size );

        if ( user_data->server_buff_map.size() > BUFFER_MAX )
            user_data->server_buff_map.erase( user_data->server_buff_map.begin() );
    }

    if ( user_data->sock == 0 )
        return;

    theNet.Write( user_data->sock, data, size );
}

void write( uint32 role_id, uint32 order, wd::CStream& stream )
{
    write( role_id, order, &stream[0], stream.length() );
}

uint32 reset_sock( int32 sock )
{
    std::map< int32, uint32 >::iterator iter = sock_map().find( sock );
    if ( iter == sock_map().end() )
        return 0;

    uint32 role_id = iter->second;

    sock_map().erase( iter );

    SData* data = find( role_id );
    if ( data != NULL )
        data->sock = 0;

    return role_id;
}

void update_sock( int32 role_id, int32 sock )
{
    SData* data = find( role_id );
    if ( data == NULL )
        return;

    if ( data->sock == sock )
        return;

    if ( data->sock != 0 )
        sock_map().erase( data->sock );

    data->sock = sock;
    sock_map()[ sock ] = role_id;
}

uint32 resend_buffer( int32 role_id, uint32 order )
{
    SData* data = find( role_id );
    if ( data == NULL )
        return 0;

    if ( data->sock == 0 )
        return 0;

    std::map< uint32, wd::CStream >::iterator iter;

    //order 为0 时为全部重发
    if ( order == 0 )
        iter = data->server_buff_map.begin();
    else
        iter = data->server_buff_map.find( order );

    if ( iter == data->server_buff_map.end() )
        return 0;

    uint32 count = 0;

    do
    {
        theNet.Write( data->sock, &iter->second[0], iter->second.length() );

        ++count;
    }
    while ( ( ++iter ) != data->server_buff_map.end() );

    return count;
}

#undef BUFFER_MAX

}// namespace user

