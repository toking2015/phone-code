#ifndef _ACCESS_USER_H_
#define _ACCESS_USER_H_

#include "common.h"
#include "pack.h"

namespace user
{

struct SData
{
    struct SBuff
    {
        int32 sock;
        int32 key;
        wd::CStream stream;
    };

    uint32 role_id;
    uint32 session;
    int32 sock;

    uint32 server_order;        //服务器操作的order
    uint32 client_order;        //客户端操作的order

    //发送到客户端的数据包缓存, 允许客户端重新请求数据包队列
    std::map< uint32, wd::CStream > server_buff_map;

    //处理来自客户端的msg order不匹配时的缓存处理, client -> game
    std::map< uint32, SBuff > client_buff_map;

    SData() : role_id(0), session(0), sock(0), server_order(0), client_order(0)
    {
    }
};

std::map< uint32, SData >& data_map(void);          //< role_id, SData >
std::map< int32, uint32 >& sock_map(void);          //< socket, role_id >

SData* find( uint32 role_id );

void delete_session( uint32 role_id );
SData* update_session( uint32 role_id, uint32 session );
bool check_session( uint32 role_id, uint32 session );

void reset_order( uint32 role_id );
uint32 pack_order_process( uint32 role_id, uint32 order );
void pack_order_push( uint32 role_id, uint32 order, int32 sock, int32 key, wd::CStream& stream );

//原始数据流，不包含 tag_pack_head
void write( uint32 role_id, uint32 order, void* data, uint32 size );
void write( uint32 role_id, uint32 order, wd::CStream& stream );

//协议通讯流封装, 包含 tag_pack_head
template< typename T >
void write( uint32 order, T& msg )
{
    msg.order = order;

    wd::CStream stream;
    stream.resize( sizeof( tag_pack_head ) );
    stream << msg;

    CPack::fill_pack_head
    (
        (tag_pack_head*)&stream[0],
        &stream[ sizeof( tag_pack_head ) ],
        stream.length() - sizeof( tag_pack_head )
    );

    write( msg.role_id, order, stream );
}

//重新发送缓存数据, 从 order 索引开始顺序往后发送, 返回发送条数; game -> client
uint32 resend_buffer( int32 role_id, uint32 order );

//如果 reset 了通过验证的用户 sock 即返回用户 role_id
uint32 reset_sock( int32 sock );

//返回 0 为更新离线用户, 返回 > 0 为被覆盖更新的在线用户 sock 值, 返回 < 0 为没有更新
void update_sock( int32 role_id, int32 sock );

}// namespace user

#endif

