#ifndef _ACCESS_PRO_H_
#define _ACCESS_PRO_H_

//@@该宏定义仅用于 PRSystemLogin 到客户端之后发送的处理协议( PQSystemPing包除外 )
//先检查 session 合法性, 然后检查数据包顺序
//顺序化数据包处理, 把类积的数据包进行转发
#define SO_PRO_ORDER_CHECK()\
    if ( !user::check_session( msg.role_id, msg.session ) )\
        return;\
    \
    uint32 client_order = user::pack_order_process( msg.role_id, msg.order );\
    if ( client_order == 0 || msg.order < client_order )\
        return;\
    \
    if ( msg.order > client_order )\
    {\
        wd::CStream stream;\
        stream.resize(4);\
        stream << msg;\
        *(uint32*)(&stream[0]) = stream.length() - 4;\
        user::pack_order_push( msg.role_id, msg.order, sock, key, stream );\
        \
        tag_msg_order msg_order;\
        msg_order.min = client_order;\
        msg_order.max = msg.order - 1;\
        \
        tag_pack_head head;\
        CPack::fill_pack_head( &head, &msg_order, sizeof( tag_msg_order ) );\
        \
        user::write( msg.role_id, 0, &head, sizeof( tag_pack_head ) );\
        user::write( msg.role_id, 0, &msg_order, sizeof( tag_msg_order ) );\
        return;\
    }

#endif //_ACCESS_PRO_H_

