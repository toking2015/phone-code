#include "epoll.h"
#include "ipc.h"
#include "CConfig.h"
#include <string.h>
#include <stdio.h>

void _server_connect_reactor(int clientid)
{
    int id = CConfig::GetInstance()->GetID();
    zmq_msg_t msg;
    zmq_msg_init_size(&msg, sizeof(int) * 3);
    memcpy(zmq_msg_data(&msg), (char*) &EVENT_CONNECT, sizeof(int));
    memcpy((char*) zmq_msg_data(&msg) + sizeof(int), (char*) &id, sizeof(int));
    memcpy((char*) zmq_msg_data(&msg) + sizeof(int) * 2, (char*) &clientid, sizeof(int));
    ipc_push(&msg);
    zmq_msg_close(&msg);
}

int _server_read_reactor(int clientid, char* buffer, int length)
{
    int id = CConfig::GetInstance()->GetID();
    short msg_length = *(short*)buffer;
    if (msg_length <= length - 2)
    {
        zmq_msg_t msg;
        zmq_msg_init_size(&msg, sizeof(int) * 3 + length+1);
        memcpy(zmq_msg_data(&msg), (char*) &EVENT_MSG, sizeof(int));
        memcpy((char*) zmq_msg_data(&msg) + sizeof(int), (char*) &id, sizeof(int));
        memcpy((char*) zmq_msg_data(&msg) + sizeof(int) * 2, (char*) &clientid, sizeof(int));
        memcpy((char*) zmq_msg_data(&msg) + sizeof(int) * 3, &buffer[2], msg_length);
        ipc_push(&msg);
        zmq_msg_close(&msg);

        return msg_length + 2;
    }

    return 0;
}

void _server_close_reactor(int clientid)
{
    int id = CConfig::GetInstance()->GetID();
    zmq_msg_t msg;
    zmq_msg_init_size(&msg, sizeof(int) * 3 + sizeof(char));
    memcpy(zmq_msg_data(&msg), (char*) &EVENT_DISCONNECT, sizeof(int));
    memcpy((char*) zmq_msg_data(&msg) + sizeof(int), (char*) &id, sizeof(int));
    memcpy((char*) zmq_msg_data(&msg) + sizeof(int) * 2, (char*) &clientid, sizeof(int));
    *(char*)(zmq_msg_data(&msg)+sizeof(int)*3) = 1;
    ipc_push(&msg);
    zmq_msg_close(&msg);
}

int server_start(int id)
{
    // 读取配置
    if (!CConfig::GetInstance()->Initialize(id, "config.xml"))
        return -1;

    const CConfig::GateConfig* gate_config = CConfig::GetInstance()->GetGateConfig(CConfig::GetInstance()->GetID());

    if (gate_config == NULL)
        return -1;

    if (epoll_start(gate_config->public_port, &_server_connect_reactor, &_server_read_reactor, &_server_close_reactor) == -1)
        return -1;

    ipc_init();

    return 0;
}

void server_stat(void)
{
    int cnt = epoll_connect_count();

    printf("Total Connections:%d\n", cnt);
}

void server_shutdown(void)
{
    ipc_close();

    epoll_shutdown();
}
