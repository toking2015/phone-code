#ifndef _IMMORTAL_ACCESSSVR_IOMGR_H_
#define _IMMORTAL_ACCESSSVR_IOMGR_H_

#include "common.h"

class CIO
{
public:
    enum
    {
        eNoExist = 0,   //不存在
        eInit = 1,      //初始化
        eOn = 2,        //在线状态
        eOff = 3,       //离线状态
    };
public:
    int32 sock;
    int32 state;

    uint32  last_recv_time;     //最后接收数据时间

    CIO();
};

class CIOMgr
{
private:
    wd::CMutex mutex;
    std::map< int32, CIO > io_map;

public:
    void AddSock( int32 sock );
    void DelSock( int32 sock );
    int32 CheckSock( int32 sock );

    std::list< int32 > GetRecvTimeoutList(void);

    void ResetRecvTime( int32 sock );

private:
    static void OnRead( void* param, int32 sock, char* buff, int32 size );
};

#define theIOMgr TSignleton< CIOMgr >::Ref()

#endif

