#include "misc.h"
#include "msg.h"
#include "proto/transfrom.h"
#include "proto/constant.h"
#include "server.h"

void OnMsgRelease( SMsgHead* msg )
{
    delete msg;
}

void OnMsgListenPre( SMsgHead* msg )
{
    server::local_time( (uint32)time(NULL) );
}

SO_LOAD( pro_proto_transfrom_init )
{
    theMsg.msg_trans_map = class_transfrom::get_handles();
    theMsg.OnMsgRelease = OnMsgRelease;

    theMsg.OnListenPre = OnMsgListenPre;

    server::local_time( (uint32)time(NULL) );
}

