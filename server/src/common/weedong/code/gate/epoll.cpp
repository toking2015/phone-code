#include "epoll.h"
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <list>

#define EPOLL_MAX_READ_BUFFER_LENGTH  2048
#define EPOLL_MAX_WRITE_BUFFER_LENGTH 2048
#define EPOLL_LISTENTHREAD_COUNT   1
#define EPOLL_READTHREAD_COUNT     4
#define EPOLL_WRITETHREAD_COUNT    1

#define MAX_CONNECTS    2000

typedef struct _tagcontext_t
{
    pthread_spinlock_t write_lock;
    int ref;
    int sockid;
    int clientid;
    int  reader_epfd;
    int  writer_epfd;
    char read_buffer[EPOLL_MAX_READ_BUFFER_LENGTH];  // 已经读取的数据
    char write_buffer[EPOLL_MAX_WRITE_BUFFER_LENGTH]; // 要发送的数据
    int read_length;
    int write_length;
}_context_t;

// 容器
_context_t* contexts_map[MAX_CONNECTS];
int contexts_sockfd_id_map[40000];
pthread_spinlock_t  contexts_map_lock;
std::list<int>   contexts_ids_list;

int _epfd = 0;
int _sock = 0;
int _port = 0;
int _started = -1;

pthread_t   _listenthread[EPOLL_LISTENTHREAD_COUNT];
pthread_t   _readthread[EPOLL_READTHREAD_COUNT];
pthread_t   _writethread[EPOLL_WRITETHREAD_COUNT];
int         _reader_epfd[EPOLL_READTHREAD_COUNT];
int         _writer_epfd[EPOLL_WRITETHREAD_COUNT];

epoll_read_reactor _rr;
epoll_accept_reactor _ar;
epoll_close_reactor _cr;

int _epoll_setnon_block(int sockfd)
{
	int opts = fcntl(sockfd , F_GETFL);
	if(-1 == opts)
		return -1;

	opts = opts | O_NONBLOCK;
	if(fcntl(sockfd , F_SETFL , opts) < 0)
		return -1;

	return 0;
}

// 内部函数
int _epoll_listensocket_init(void)
{
    _sock = socket(PF_INET, SOCK_STREAM, 0);
    if (_sock == -1)
        return -1;

    int reuse = 1;
    setsockopt(_sock , SOL_SOCKET , SO_REUSEADDR , &reuse , sizeof(reuse));

    // 设置非阻塞模式
    _epoll_setnon_block(_sock);

	// 绑定端口
	struct sockaddr_in servaddr;
	bzero(&servaddr, sizeof(servaddr));

	servaddr.sin_family = PF_INET;
	servaddr.sin_port = htons(_port);
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);

	int ret = bind(_sock , (struct sockaddr*)&servaddr , sizeof(servaddr));
	if(ret == -1)
	{
		close(_sock);
		_sock = -1;
		return -1;
	}

	ret = listen(_sock , 400);
	if(ret == -1)
	{
		close(_sock);
		_sock = -1;
		return -1;
	}

	return 0;
}

void _epoll_listensocket_close(void)
{
	if (_sock != -1)
	{
		close(_sock);
		_sock = -1;
	}
}

int _epoll_contexts_init(void)
{
    pthread_spin_init(&contexts_map_lock, 0);
    memset(contexts_map, 0, sizeof(contexts_map));
    memset(contexts_sockfd_id_map, 0, sizeof(contexts_sockfd_id_map));
    int i=0;
    for (;i<=MAX_CONNECTS; i++)
        contexts_ids_list.push_back(i);
    return 0;
}

void _epoll_contexts_destroy(void)
{
    memset(contexts_map, 0, sizeof(contexts_map));
    memset(contexts_sockfd_id_map, 0, sizeof(contexts_sockfd_id_map));
    pthread_spin_destroy(&contexts_map_lock);
    contexts_ids_list.clear();
}

_context_t* _epoll_context_add(int sockid)
{
    _context_t* context = NULL;

    pthread_spin_lock(&contexts_map_lock);

    if (!contexts_ids_list.empty())
    {
        int clientid = contexts_ids_list.front();
        contexts_ids_list.pop_front();

        if (contexts_map[clientid] != NULL)
        {
            context = NULL;
        }
        else
        {
            context = (_context_t*) malloc(sizeof(_context_t));
            memset(context, 0, sizeof(_context_t));
            pthread_spin_init(&context->write_lock, 0);
            context->sockid = sockid;
            context->clientid = clientid;

            contexts_map[clientid] = context;
            contexts_sockfd_id_map[sockid] = clientid;

            // 初始化引用计数
            __sync_fetch_and_add(&context->ref, 2);
        }
    }

    pthread_spin_unlock(&contexts_map_lock);

    return context;
}

_context_t* _epoll_context_get(int clientid)
{
    _context_t* val = NULL;

    pthread_spin_lock(&contexts_map_lock);

    val = contexts_map[clientid];

    if (val != NULL)
    {
        // 增加引用计数
        __sync_add_and_fetch(&val->ref, 1);
    }

    pthread_spin_unlock(&contexts_map_lock);

    return val;
}

void _epoll_context_put(_context_t* context)
{
    int ret = __sync_sub_and_fetch(&context->ref, 1);
    if (ret == 0)
    {
        // 从容器里面释放
        pthread_spin_destroy(&context->write_lock);
        free(context);
    }
}

void _epoll_context_remove(int clientid)
{
    _context_t* val;

    pthread_spin_lock(&contexts_map_lock);

    val = contexts_map[clientid];

    if (val != NULL)
    {
        if (__sync_sub_and_fetch(&val->ref, 1) == 0)
        {
            pthread_spin_destroy(&val->write_lock);
            free(val);
        }
    }

    contexts_map[clientid] = NULL;

    contexts_ids_list.push_back(clientid);

    pthread_spin_unlock(&contexts_map_lock);
}

int _epoll_accept(int sockfd)
{
	struct epoll_event ev;
	bzero(&ev , sizeof(ev));

	_epoll_setnon_block(sockfd);
	ev.data.fd = sockfd;
	ev.events = EPOLLIN | EPOLLET;

	_context_t *context = _epoll_context_add(sockfd);

	if (context == NULL)
        return -1;

    int clientid = context->clientid;

    // 设置读
	int epfd = _reader_epfd[sockfd % EPOLL_READTHREAD_COUNT];
	epoll_ctl(epfd, EPOLL_CTL_ADD , sockfd , &ev);

	int sender_epfd = _writer_epfd[sockfd % EPOLL_WRITETHREAD_COUNT];

	context->reader_epfd = epfd;
	context->writer_epfd = sender_epfd;

	_epoll_context_put(context);

	return clientid;
}

int _epoll_create(void)
{
	if (_sock == -1)
		return -1;

	// 侦听Epoll FD
	_epfd = epoll_create(256);

	struct epoll_event ev;
	bzero(&ev , sizeof(ev));
	ev.data.fd = _sock;
	ev.events = EPOLLIN;// | EPOLLET;

	if (epoll_ctl(_epfd , EPOLL_CTL_ADD , _sock, &ev) == -1)
	{
		close(_epfd);
		_epfd = 0;
		return -1;
	}

	return 0;
}

// 处理线程
void* _epoll_listenthread_proc(void* arg)
{
    int i;

	int nfds = 0;

	int newsocket = 0;

	struct epoll_event events[1000];

	while (_started != -1)
	{
		nfds = epoll_wait(_epfd , events , 1000, 10);

		for (i=0; i<nfds; i++)
		{
			if (events[i].data.fd == _sock)
			{
				newsocket = accept(_sock, NULL , NULL);
				if(newsocket == -1)
				{
					if(errno == EINTR)
						continue;
				}
				else
				{
					// 接收联接
					int clientid = _epoll_accept(newsocket);
					if (clientid == -1)
					{
					    close(newsocket);
					}
					else
					{
					    if (_ar != NULL)
                            (*_ar)(clientid);
					}
				}
			}
		}
	}

	return 0;
}

int _epoll_find_readerepfd(pthread_t pthreadid)
{
    int i;
    for (i=0; i<EPOLL_READTHREAD_COUNT; i++)
    {
        if (_readthread[i] == pthreadid)
            return _reader_epfd[i];
    }

    return 0;
}

int _epoll_find_writerepfd(pthread_t pthreadid)
{
    int i;
    for (i=0; i<EPOLL_WRITETHREAD_COUNT; i++)
    {
        if (_writethread[i] == pthreadid)
            return _writer_epfd[i];
    }

    return 0;
}

int _epoll_read(int sockfd, char* buffer, size_t size)
{
    int read_size = read(sockfd , buffer , size);    ///返回接收数据大小
	if(read_size <= 0)
		return -1;

	return read_size;
}

void* _epoll_readthread_proc(void* arg)
{
    int i;
    int nfds , sock;
	struct epoll_event ev;
	struct epoll_event events[1000];
	char buffer[2048];

	int epfd = _epoll_find_readerepfd(pthread_self());
	while (_started != -1)
	{
		nfds = epoll_wait(epfd, events, 1000, 10);

		for (i=0;i<nfds;i++)
		{
			if (events[i].events & EPOLLIN)	// 读取事件
			{
				if((sock = events[i].data.fd) < 0)
					continue;

                int size = _epoll_read(sock, buffer, sizeof(buffer));

                    if (size == -1)	// 端口断开
                    {
                        // 断开连接
                        //epoll_close(sock);
                        struct epoll_event ev;
                        ev.data.fd = sock;
                        epoll_ctl(epfd , EPOLL_CTL_DEL , sock , &ev);
                        if (_cr != NULL)    // 等反馈后再关闭端口，防止端口重复
                            (*_cr)(contexts_sockfd_id_map[sock]);
                        else
                            epoll_close(contexts_sockfd_id_map[sock]);
                        events[i].data.fd = -1;
                    }
                    else
                    {
                        if (size > 0)
                        {
                            _context_t* context = _epoll_context_get(contexts_sockfd_id_map[sock]);

                            if (context != NULL)
                            {
                                memcpy(&context->read_buffer[context->read_length], buffer, size);

                                context->read_length += size;

                                int process_size = 0;
                                if (_rr != NULL)
                                {
                                    while (1)
                                    {
                                        int ret = (*_rr)(context->clientid, &context->read_buffer[process_size], context->read_length - process_size);
                                        if (ret == 0)
                                            break;
                                        process_size += ret;

                                        if (context->read_length - process_size == 0)
                                            break;
                                    }
                                }
                                else
                                    process_size = context->read_length;

                                if (process_size == -1)
                                {
                                    struct epoll_event ev;
                                    ev.data.fd = sock;
                                    epoll_ctl(epfd , EPOLL_CTL_DEL , sock , &ev);
                                    if (_cr != NULL)    // 等反馈后再关闭端口，防止端口重复
                                        (*_cr)(context->clientid);
                                    epoll_close(context->clientid);
                                    events[i].data.fd = -1;
                                }
                                else if (process_size > 0)
                                {
                                    int left_size = context->read_length - process_size;
                                    if (left_size > 0)
                                        memcpy(context->read_buffer, &context->read_buffer[context->read_length], left_size);
                                    context->read_length = 0;
                                }
                                context->read_length = 0;

                                _epoll_context_put(context);
                            }
                            else
                            {
                                struct epoll_event ev;
                                ev.data.fd = sock;
                                epoll_ctl(epfd , EPOLL_CTL_DEL , sock , &ev);
                                close(sock);
                            }
                        }
                    }

			}
		}
	}

	return 0;
}

void* _epoll_writethread_proc(void* arg)
{
	int sock, i, nfds;
	struct epoll_event ev, events[1000];

	sigset_t signal_mask;
    sigemptyset (&signal_mask);
    sigaddset (&signal_mask, SIGPIPE);
    int rc = pthread_sigmask (SIG_BLOCK, &signal_mask, NULL);
    if (rc != 0) printf("block sigpipe error/n");

	int efpd = _epoll_find_writerepfd(pthread_self());

    while (_started != -1)
    {
        nfds = epoll_wait(efpd, events, 1000, 10);

		for (i=0;i<nfds;i++)
		{
			if (events[i].events & EPOLLOUT)
			{
				sock = events[i].data.fd;

				if (sock == -1)
					continue;

				// 发送数据
				_context_t* context = _epoll_context_get(contexts_sockfd_id_map[sock]);
				if (context != NULL)
				{
				    pthread_spin_lock(&context->write_lock);

				    if (context->write_length > 0)
				    {
				        // 这里有优化的空间，采用写指针，减少一次拷贝
				        int length = context->write_length;
				        int left_size = 0;

				        int size = send(sock, context->write_buffer, context->write_length, 0);

				        if (size > 0)
                        {
                            left_size = context->write_length - size;
                            if (left_size <= 0)
                            {
                                // 没有内容了，取消写
                                ev.data.fd= sock;
                                epoll_ctl(efpd , EPOLL_CTL_DEL , sock , &ev);
                            }
                            else
                            {
                                memcpy(context->write_buffer, &context->write_buffer[context->write_length], left_size);
                            }

                            context->write_length = left_size;
                        }
                        else
                        {
                            // 没有内容了，取消写
                            ev.data.fd= sock;
                            epoll_ctl(efpd , EPOLL_CTL_DEL , sock , &ev);
                        }
				    }

				    pthread_spin_unlock(&context->write_lock);

				    _epoll_context_put(context);
				}
			}
			if (events[i].events & EPOLLERR)
			{
				ev.data.fd= sock;
                epoll_ctl(efpd , EPOLL_CTL_DEL , sock , &ev);
				events[i].data.fd = -1;
			}
		}
    }

    return 0;
}

int _epoll_thread_listen_start(void)
{
    int i;
	for (i=0;i<EPOLL_LISTENTHREAD_COUNT;i++)
	{
		pthread_t threadid;
		pthread_create(&threadid,NULL,_epoll_listenthread_proc,NULL);
		_listenthread[i] = threadid;
	}

	return i;
}

int _epoll_thread_listen_end(void)
{
    int i;
	for (i=0;i<EPOLL_LISTENTHREAD_COUNT;i++)
	{
		pthread_cancel(_listenthread[i]);
	}

	memset(_listenthread, 0, sizeof(_listenthread));
}

int _epoll_thread_read_start(void)
{
    int i;
	for (i=0;i<EPOLL_READTHREAD_COUNT;i++)
	{
		pthread_t threadid;
		pthread_create(&threadid,NULL,_epoll_readthread_proc,NULL);
		_readthread[i] = threadid;
		_reader_epfd[i] = epoll_create(256);
	}

	return i;
}

int _epoll_thread_read_end(void)
{
    int i;
	for (i=0;i<EPOLL_READTHREAD_COUNT;i++)
	{
		pthread_cancel(_readthread[i]);
	}

	memset(_readthread, 0, sizeof(_readthread));
}

int _epoll_thread_write_start(void)
{
    int i;
	for (i=0;i<EPOLL_WRITETHREAD_COUNT;i++)
	{
		pthread_t threadid;
		pthread_create(&threadid,NULL,_epoll_writethread_proc,NULL);
		_writethread[i] = threadid;
		_writer_epfd[i] = epoll_create(256);
	}

	return i;
}

int _epoll_thread_write_end(void)
{
    int i;
	for (i=0;i<EPOLL_WRITETHREAD_COUNT;i++)
	{
		pthread_cancel(_writethread[i]);
	}

	memset(_writethread, 0, sizeof(_writethread));
}

void _epoll_destroy(void)
{
    int i;
	if (_epfd != 0)
	{
		close(_epfd);
		_epfd = 0;
	}

	_started = -1;

	for (i=0; i<EPOLL_READTHREAD_COUNT; i++)
		close(_reader_epfd[i]);

	memset(_reader_epfd, 0, sizeof(_reader_epfd));

	for (i=0; i<EPOLL_WRITETHREAD_COUNT; i++)
		close(_writer_epfd[i]);

	memset(_writer_epfd, 0, sizeof(_writer_epfd));
}

int epoll_start(int port, epoll_accept_reactor ar, epoll_read_reactor rr, epoll_close_reactor cr)
{
    _port = port;

    if (_epoll_listensocket_init() == -1)
        return -1;

    if (_epoll_create() == -1)
    {
        _epoll_listensocket_close();
        return -1;
    }

    _started = 0;

    if (_epoll_thread_listen_start() == -1)
    {
        _epoll_destroy();
        _epoll_listensocket_close();
        return -1;
    }

    if (_epoll_thread_read_start() == -1)
    {
        _epoll_thread_listen_end();
        _epoll_destroy();
        _epoll_listensocket_close();
        return -1;
    }

    if (_epoll_thread_write_start() == -1)
    {
        _epoll_thread_read_end();
        _epoll_thread_listen_end();
        _epoll_destroy();
        _epoll_listensocket_close();
        return -1;
    }

    _epoll_contexts_init();

    _ar = ar;
    _rr = rr;
    _cr = cr;

    return 0;
}

int epoll_send(int clientid, char* buffer, size_t size)
{
    _context_t* context = _epoll_context_get(clientid);

    if (context == NULL || size == 0 || size >= EPOLL_MAX_WRITE_BUFFER_LENGTH)
        return -1;

    pthread_spin_lock(&context->write_lock);

    int total_length = context->write_length + size;

    if (total_length >= EPOLL_MAX_WRITE_BUFFER_LENGTH)
    {
        size = size - (total_length - EPOLL_MAX_WRITE_BUFFER_LENGTH);
    }

    memcpy(&context->write_buffer[context->write_length], buffer, size);
    context->write_length += size;

    pthread_spin_unlock(&context->write_lock);

    int sockfd = context->sockid;

    _epoll_context_put(context);

    // 设置写
	struct epoll_event wev;
	bzero(&wev , sizeof(wev));
	wev.data.fd = sockfd;
	wev.events = EPOLLOUT | EPOLLERR;
	int sender_epfd = _writer_epfd[sockfd % EPOLL_WRITETHREAD_COUNT];
	epoll_ctl(sender_epfd , EPOLL_CTL_ADD , sockfd , &wev);

    return size;
}

void epoll_close(int clientid)
{
    _context_t* context = _epoll_context_get(clientid);
    if (context != NULL)
    {
        close(context->sockid);

        _epoll_context_remove(clientid);

        _epoll_context_put(context);
    }
}

int epoll_connect_count(void)
{
    int cnt = 0, i;
    pthread_spin_lock(&contexts_map_lock);

    for (i=0; i<MAX_CONNECTS; i++)
    {
        if (contexts_map[i] != NULL)
            cnt++;
    }

    pthread_spin_unlock(&contexts_map_lock);

    return cnt;
}

void epoll_shutdown(void)
{
    _started = -1;

    _epoll_thread_listen_end();
    _epoll_thread_read_end();
    _epoll_thread_write_end();
    _epoll_listensocket_close();

    _epoll_contexts_destroy();
}
