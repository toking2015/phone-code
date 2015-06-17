#ifndef EPOLL_H_INCLUDED
#define EPOLL_H_INCLUDED

#include <pthread.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <stdarg.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/epoll.h>
#include <fcntl.h>

typedef int (*epoll_read_reactor)(int clientid, char* buffer, int size);

typedef void (*epoll_accept_reactor)(int clientid);

typedef void (*epoll_close_reactor)(int clientid);

int epoll_start(int port, epoll_accept_reactor ar, epoll_read_reactor rr, epoll_close_reactor cr);

void epoll_shutdown(void);

int epoll_connect_count(void);

int epoll_send(int clientid, char* buffer, size_t size);

void epoll_close(int clientid);

#endif // EPOLL_H_INCLUDED
