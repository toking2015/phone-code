#ifndef IPC_H_INCLUDED
#define IPC_H_INCLUDED

#include <zmq.h>

const int EVENT_CONNECT = 0;
const int EVENT_MSG = 0x1000;
const int EVENT_DISCONNECT = 0x1000;

int ipc_init(void);

void ipc_push(zmq_msg_t* msg);

void ipc_close(void);

#endif // IPC_H_INCLUDED
