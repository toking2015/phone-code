#include "ipc.h"
#include "CConfig.h"
#include "epoll.h"
#include <stdio.h>
#include <string.h>
#include <pthread.h>

void* _zmq_receiver = NULL;
void* _zmq_sender;
void* _zmq_context = NULL;
pthread_t _zmq_thread = 0;
int _ipc_started = 0;
pthread_spinlock_t _zmq_job_lock;

void* ipc_proc(void* arg)
{
    int cmd = 0, sockid = 0;
    zmq_msg_t message;
    while (_ipc_started != -1)
    {
        cmd = 0;

        zmq_msg_init(&message);
        int ret = zmq_recvmsg (_zmq_receiver, &message, 0);

        if (ret <= 0)
        {
            zmq_msg_close(&message);
            continue;
        }

        int size = zmq_msg_size (&message);
        memcpy(&cmd, zmq_msg_data(&message), sizeof(int));
        if (cmd == EVENT_MSG)
        {
            memcpy(&sockid, (char*) zmq_msg_data(&message) + sizeof(int), sizeof(int));
            epoll_send(sockid, (char*) zmq_msg_data(&message) + sizeof(int)*2, size - sizeof(int) * 2);
        }

        zmq_msg_close (&message);
    }

    return 0;
}

int ipc_init(void)
{
    const CConfig::GateConfig* gate_config = CConfig::GetInstance()->GetGateConfig(CConfig::GetInstance()->GetID());

    if (gate_config == NULL)
        return -1;

    _zmq_context = zmq_init (1);

    char ipc_cmd[32];
    sprintf(ipc_cmd, "tcp://%s:%d", gate_config->send_to.ip, gate_config->send_to.port);

    _zmq_sender = zmq_socket(_zmq_context, ZMQ_PUSH);
    zmq_connect (_zmq_sender, ipc_cmd);

    sprintf(ipc_cmd, "tcp://%s:%d", gate_config->ip, gate_config->port);

    _zmq_receiver = zmq_socket(_zmq_context, ZMQ_PULL);
    zmq_bind(_zmq_receiver, ipc_cmd);

    int rcvbuf = 10240;
    zmq_setsockopt(_zmq_receiver, ZMQ_RCVBUF, &rcvbuf, sizeof(int));
    zmq_setsockopt(_zmq_sender, ZMQ_SNDBUF, &rcvbuf, sizeof(int));

    _ipc_started = 0;

    // 启动工作线程
    pthread_create(&_zmq_thread,NULL,ipc_proc,NULL);

    pthread_spin_init(&_zmq_job_lock, 0);

    return 0;
}

void ipc_push(zmq_msg_t* msg)
{
    if (msg == NULL)
        return;

    pthread_spin_lock(&_zmq_job_lock);
    zmq_sendmsg(_zmq_sender, msg, 0);
    pthread_spin_unlock(&_zmq_job_lock);
}

void ipc_close(void)
{
    _ipc_started = -1;
    zmq_close (_zmq_sender);
    zmq_close(_zmq_receiver);
    close(_zmq_thread);
    zmq_term(_zmq_context);
}
