#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "server.h"

void init_daemon(void)
{
    int pid, i;

    if(pid=fork())
    {
        exit(0);//是父进程，结束父进程
    }
    else if(pid < 0)
    {
        exit(1);
    }

    setsid();//第一子进程成为新的会话组长和进程组长并与控制终端分离

    if(pid=fork())
    {
        exit(0);//是第一子进程，结束第一子进程
    }
    else if(pid< 0)
    {
        exit(1);
    }

    for(i=0;i< NOFILE;++i)//关闭打开的文件描述符
        close(i);

    umask(0);//重设文件创建掩模
}

int main(int argc, char* argv[])
{
    int id = 0;
    if (argc >= 2)
    {
        id = atoi(argv[1]);
    }

    int i=0;
    for (;i<argc; i++)
    {
        if (strcmp(argv[i], "-d") == 0)
        {
            init_daemon();
            break;
        }
    }

    server_start(id);

    while (1)
    {
        sleep(60);
    }

    server_shutdown();

    return 0;
}
