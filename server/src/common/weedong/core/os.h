#ifndef _WEEDONG_CORE_OS_H_
#define _WEEDONG_CORE_OS_H_

#include <time.h>
#include <errno.h>

#ifndef WIN32
#define LINUX
#endif

#if defined LINUX

#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/unistd.h>
#include <semaphore.h>

#elif defined WIN32

#define _WIN32_WINNT 0x0501
#define WINVER 0x0501
#include <windows.h>
#include <winbase.h>
#include <process.h>
#include <shlwapi.h>
#include <stdio.h>

#endif //#if defined LINUX

#if defined(WIN32) && defined(WD_BUILD_AS_DLL)

#if defined(WD_LIB)
#define WD_API __declspec(dllexport)
#else
#define WD_API __declspec(dllimport)
#endif

#else

#define WD_API 

#endif //#if defined(WIN32) && defined(WD_BUILD_AS_DLL)


typedef unsigned char byte;
typedef unsigned short ushort;
typedef unsigned int uint;

typedef char int8;
typedef unsigned char uint8;

typedef short int16;
typedef unsigned short uint16;

typedef int int32;
typedef unsigned int uint32;

#ifdef LINUX
typedef long long int64;
typedef unsigned long long uint64;
#else
typedef __int64 int64;
typedef unsigned __int64 uint64;
#endif

// time
#if defined LINUX

#include <sys/time.h>
typedef time_t time64;

#elif defined WIN32

#include <time.h>
typedef __int64 time64;

#endif

namespace wd
{

//==================================================================
// 时间操作函数
WD_API void gettime( time64 &pTime );   //获取当前 time64 时间
WD_API void localtime_r( struct tm &pTm, time64 &pTime );
WD_API struct tm localtime(void);

// thread
#if defined LINUX

typedef pthread_t         thread_id;
typedef pthread_t         thread_t;
typedef pthread_mutex_t   mutex_t;
typedef sem_t             semaphore_t;

#elif defined WIN32

typedef DWORD             thread_id;
typedef HANDLE            thread_t;
typedef CRITICAL_SECTION  mutex_t;
typedef HANDLE            semaphore_t;

#endif

//================================================================================================
// 线程操作函数

// 线程回调函数原型
typedef unsigned int (*thread_proc_t)(void*);

/*************************************************
  Description:    // 创建线程
  Input:          // new_thread_handle 线程句柄
                  // start_routine 线程回调函数
                  // arg 线程参数
  Output:         // 0 成功 -1 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int      thread_create(thread_t* new_thread_handle, thread_proc_t start_routine, void* arg);

/*************************************************
  Description:    // 离开线程并传回错误码 线程回调函数内使用
  Input:          // code 错误码
  Output:         // 
  Return:         // 
  Others:         // 
*************************************************/
WD_API void     thread_exit(unsigned long code);

/*************************************************
  Description:    // 关闭线程句柄
  Input:          // thread_handle 线程句柄
  Output:         // 
  Return:         // 
  Others:         // 
*************************************************/
WD_API void     thread_close_handle(thread_t* thread_handle);

/*************************************************
  Description:    // 等待线程退出
  Input:          // thread_handle 线程句柄
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int      thread_wait_exit(thread_t* thread_handle);

/*************************************************
  Description:    // 取当前线程id
  Input:          // 
  Output:         // thread_id 线程ID
  Return:         // 
  Others:         // 
*************************************************/
WD_API thread_id    thread_get_current_id(void);

/*************************************************
  Description:    // sleep当前线程 
  Input:          // milliseconds 毫秒
  Output:         // 
  Return:         // 
  Others:         // 
*************************************************/
WD_API void     thread_sleep(uint32 milliseconds);

/*************************************************
  Description:    // 取机器毫秒 
  Input:          // 
  Output:         // 毫秒
  Return:         // 
  Others:         // 
*************************************************/
WD_API uint32   get_tick(void);
//================================================================================================


//================================================================================================
// 互斥操作函数

/*************************************************
  Description:    // 创建互斥 
  Input:          // mutex_ptr 外层指针
  Output:         // 0 成功 非零失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int  mutex_create(mutex_t* mutex_ptr);

/*************************************************
  Description:    // 释放互斥 
  Input:          // mutex_ptr 外层指针
  Output:         // 0 成功 非零失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int  mutex_destroy(mutex_t* mutex_ptr);

/*************************************************
  Description:    // 锁互斥 
  Input:          // mutex_ptr 外层指针
  Output:         // 0 成功 非零失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int  mutex_lock(mutex_t* mutex_ptr);

/*************************************************
  Description:    // 尝试锁互斥 
  Input:          // mutex_ptr 外层指针
  Output:         // 0 成功 非零失败
  Return:         // 
  Others:         // 只有成功时才需要解锁
*************************************************/
WD_API int  mutex_trylock(mutex_t* mutex_ptr);

/*************************************************
  Description:    // 解锁互斥 
  Input:          // mutex_ptr 外层指针
  Output:         // 0 成功 非零失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int  mutex_unlock(mutex_t* mutex_ptr);
//================================================================================================


//================================================================================================
// 自旋锁操作函数

typedef struct _spin_lock_t* spin_lock_t;

/*************************************************
  Description:    // 创建自旋锁 
  Input:          // spin_lock 外层指针
  Output:         // 
  Return:         // 
  Others:         // 
*************************************************/
WD_API void spin_lock_create(spin_lock_t* spin_lock);

/*************************************************
  Description:    // 销毁自旋锁 
  Input:          // spin_lock 外层指针
  Output:         // 
  Return:         // 
  Others:         // 
*************************************************/
WD_API void spin_lock_destroy(spin_lock_t* spin_lock);

/*************************************************
  Description:    // 锁自旋锁 
  Input:          // spin_lock 外层指针
  Output:         // 
  Return:         // 
  Others:         // 
*************************************************/
WD_API void spin_lock_lock(spin_lock_t* spin_lock);

/*************************************************
  Description:    // 尝试锁自旋锁 
  Input:          // spin_lock 外层指针
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 只有成功时才需要解锁
*************************************************/
WD_API int spin_lock_trylock(spin_lock_t* spin_lock);

/*************************************************
  Description:    // 解锁自旋锁 
  Input:          // spin_lock 外层指针
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int spin_lock_unlock(spin_lock_t* spin_lock);
//================================================================================================


//================================================================================================
// 信号量操作函数

/*************************************************
  Description:    // 创建信号量 
  Input:          // semaphore 外层指针
                  // init_count 信号的初始计数
                  // max_count 信号的最大计数
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int semaphore_create(semaphore_t* semaphore, int init_count, int max_count);

/*************************************************
  Description:    // 释放一个信号量 
  Input:          // semaphore 外层指针
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int semaphore_put(semaphore_t* semaphore);

/*************************************************
  Description:    // 获取一个信号 
  Input:          // semaphore 外层指针
                  // milli_secs 等待毫秒数
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int semaphore_get(semaphore_t* semaphore, uint32 milli_secs);

/*************************************************
  Description:    // 释放信号量 
  Input:          // semaphore 外层指针
  Output:         // 0 成功 非零 失败
  Return:         // 
  Others:         // 
*************************************************/
WD_API int semaphore_destroy(semaphore_t* semaphore);
//================================================================================================

class WD_API CThread
{
public:
    CThread();
    virtual ~CThread();

    void StartThread();
    thread_t* GetHandle();

    virtual void EndThread() = 0;
    virtual uint32 Run() = 0;

public:
    void (*OnThreadBegin)(void);
    void (*OnThreadEnd)(void);

private:
    thread_t m_hThread;
};

class WD_API CMutex
{
public:
    CMutex();
    ~CMutex();

    void Lock();
    void UnLock();
    bool TryLock();

private:
    mutex_t m_Mutex;
};

class WD_API CSpinLock
{
public:
    CSpinLock();
    ~CSpinLock();

    void Lock();
    void UnLock();
    bool TryLock();

private:
    spin_lock_t m_SpinLock;
};

class WD_API CSemaphore
{
public:
    CSemaphore(int init_count, int max_count);
    ~CSemaphore();

    int Put();
    int Get(uint32 milli_secs);

private:
    semaphore_t m_Semaphore;
};

template<typename T>
class CGuard
{
public:
    CGuard(T* p):m_pLock(p)
    {
        m_pLock->Lock();
    }

    ~CGuard()
    {
        UnLock();
    }

    void UnLock()
    {
        if ( m_pLock != NULL )
        {
            m_pLock->UnLock();
        }
        m_pLock = NULL;
    }

private:
    T*  m_pLock;
};

};

#endif
