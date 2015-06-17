#include "os.h"
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sstream>

namespace wd
{

void gettime( time64 &pTime )
{
#ifdef LINUX
	time( (time_t*)&pTime );
#else
	_time64( &pTime );
#endif      
}

void localtime_r( struct tm &pTm, time64 &pTime )
{
#ifdef LINUX
	localtime_r( &pTime, &pTm );
#else
	_localtime64_s( &pTm, &pTime );
#endif  
}

tm localtime(void)
{
    time64 timeval; 
    struct tm timenow;

    gettime( timeval );
    localtime_r( timenow, timeval );

    return timenow;
}

typedef struct _thread_args 
{
    thread_proc_t fn;
    void* args;
}thread_args;

#if defined WIN32
static unsigned int __stdcall my_thread_proc_t(void* args)
{
    thread_args* th = (thread_args*)args;
    unsigned int result = (th->fn)(th->args);
    free(th);
    return result;
}
#elif defined LINUX
static void* my_thread_proc_t(void* args)
{
    thread_args* th = (thread_args*)args;
    void* result = (void*)(th->fn)(th->args);
    free(th);
    return result;
}
#endif

WD_API int thread_create(thread_t* new_thread_handle, thread_proc_t start_routine, void* arg)
{
	if (start_routine == NULL)
		return -1;

    thread_args* thread = (thread_args*)malloc(sizeof(thread_args));
    thread->fn = start_routine;
    thread->args = arg;

#if defined LINUX
	int nRetCode = pthread_create(new_thread_handle, NULL, my_thread_proc_t, thread);
	if (nRetCode != 0)
		return -1;
#elif defined WIN32
	unsigned ThreadID;
	*new_thread_handle = (HANDLE)_beginthreadex(0, 0, my_thread_proc_t, thread, 0, &ThreadID);
	if (*new_thread_handle == NULL)
		return -1;
#endif
	return 0;
}

WD_API void     thread_exit(unsigned long code)
{
#if defined LINUX
    pthread_exit(&code);
#elif defined WIN32
    _endthreadex(code);
#endif
}

WD_API void thread_close_handle(thread_t* thread_handle)
{
    if (thread_handle == NULL)
    {
        return;
    }

#if defined LINUX
    pthread_detach(*thread_handle);
#elif defined WIN32
    CloseHandle(*thread_handle);
#endif
}

WD_API thread_id thread_get_current_id(void)
{
#if defined LINUX 
    return pthread_self();
#elif defined WIN32
    return GetCurrentThreadId();
#endif 
}

WD_API int thread_wait_exit(thread_t* thread_handle)
{
    int nRetCode = 0;

#if defined LINUX
    nRetCode = pthread_join(*thread_handle, NULL);
    *thread_handle = 0;    
#elif defined WIN32
    nRetCode = WaitForSingleObject(*thread_handle, INFINITE);
    switch (nRetCode)
    {
    case WAIT_FAILED:
        nRetCode = 1;
        break;
    case WAIT_ABANDONED:
    case WAIT_OBJECT_0:
        CloseHandle(*thread_handle);
        *thread_handle	= NULL;
        nRetCode = 0;
        break; 
    default:
        break;
    }
#endif
    return nRetCode;
}

WD_API void thread_sleep(uint32 milliseconds)
{
#if defined LINUX 
    timespec ts;
    ts.tv_sec	= milliseconds / 1000;
    ts.tv_nsec	= milliseconds % 1000 * 1000000;
    if (-1 == nanosleep(&ts,&ts))
    {
        std::ostringstream strm;
        strm << "nanosleep failed with error:" << strerror(errno) << std::endl;
        printf(strm.str().c_str());
    }
#elif defined WIN32
    Sleep(milliseconds);
#endif
}

WD_API uint32 get_tick(void)
{
#if defined LINUX 
    struct timeval val;
    gettimeofday(&val, NULL);
    return (val.tv_sec *1000 + val.tv_usec / 1000);
#elif defined WIN32
    return GetTickCount();
#endif
}

WD_API int  mutex_create(mutex_t* mutex_ptr)
{
    if (mutex_ptr == NULL)
    {
        return -1;
    }

#if defined LINUX
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE_NP);
    int ret = pthread_mutex_init(mutex_ptr, &attr);
    pthread_mutexattr_destroy(&attr);
    return ret;
#elif defined WIN32
    InitializeCriticalSection(mutex_ptr);
    return 0;
#endif
}

WD_API int  mutex_destroy(mutex_t* mutex_ptr)
{
    if (mutex_ptr == NULL)
    {
        return -1;
    }

#if defined LINUX 
    if ((pthread_mutex_destroy(mutex_ptr)) == 0)
        return 0;
    else
        return -1;
#elif defined WIN32
    DeleteCriticalSection(mutex_ptr);
    return 0;
#endif
}

WD_API int  mutex_lock(mutex_t* mutex_ptr)
{
    if (mutex_ptr == NULL)
    {
        return -1;
    }

#if defined LINUX 
    if ((pthread_mutex_lock(mutex_ptr)) == 0) 
        return 0;
    else
        return -1;
#elif defined WIN32
    EnterCriticalSection(mutex_ptr);
    return 0;
#endif
}

WD_API int  mutex_trylock(mutex_t* mutex_ptr)
{
    int ret_code = 0; 

    if (mutex_ptr == NULL)
    {
        return -1;
    }

#if defined LINUX 
    if ((ret_code = pthread_mutex_trylock(mutex_ptr)) == 0) 
        return 0;
    else
        return -1;
#elif defined WIN32
    if (TryEnterCriticalSection(mutex_ptr))
        return 0;
    else
        return -1;
#endif
}

WD_API int  mutex_unlock(mutex_t* mutex_ptr)
{
    int ret_code = 0; 

    if (mutex_ptr == NULL)
    {
        return -1;
    }

#if defined LINUX 
    if ((ret_code = pthread_mutex_unlock(mutex_ptr)) == 0) 
        return 0;
    else
        return -1;
#elif defined WIN32
    LeaveCriticalSection(mutex_ptr);
    return 0;
#endif
}


const unsigned int YIELD_ITERATION = 30;
const unsigned int MAX_SLEEP_ITERATION = 40; 
const int SeedVal = 100;

typedef struct _spin_lock_t
{
    uint32 dest;
    uint32 exchange;
    uint32 compare;
}*spin_lock_t;

static int OSAtomicCompareAndSwap32(uint32 *value, uint32 new_value, uint32 old_value)
{
#if defined LINUX
    return (__sync_val_compare_and_swap(value, old_value, new_value) == 0)?1:0;
#elif defined WIN32
    return (InterlockedCompareExchange((LONG*)value, new_value, old_value) == 0)?1:0;
#endif
}

WD_API void spin_lock_create(spin_lock_t* spin_lock)
{
    *spin_lock = (spin_lock_t)malloc(sizeof(_spin_lock_t));
    if (*spin_lock)
    {
        (*spin_lock)->dest = 0;
        (*spin_lock)->exchange = SeedVal;
        (*spin_lock)->compare = 0;
    }
}

WD_API void spin_lock_destroy(spin_lock_t* spin_lock)
{
    free(*spin_lock);
}

WD_API void spin_lock_lock(spin_lock_t* spin_lock)
{
    uint32 iterations = 0;
	while(true)
	{
		// A thread alreading owning the lock shouldn't be allowed to wait to acquire the lock - reentrant safe
		if((*spin_lock)->dest == thread_get_current_id())
			break;
		/*
		  Spinning in a loop of interlockedxxx calls can reduce the available memory bandwidth and slow
		  down the rest of the system. Interlocked calls are expensive in their use of the system memory
		  bus. It is better to see if the 'dest' value is what it is expected and then retry interlockedxx.
		*/
		if(OSAtomicCompareAndSwap32(&((*spin_lock)->dest), (*spin_lock)->exchange, (*spin_lock)->compare))
		{
			//assign CurrentThreadId to dest to make it re-entrant safe
			(*spin_lock)->dest = thread_get_current_id();
			// lock acquired 
			break;			
		}
			
		// spin wait to acquire 
		while((*spin_lock)->dest != (*spin_lock)->compare)
		{
			if(iterations >= YIELD_ITERATION)
			{
				if(iterations + YIELD_ITERATION >= MAX_SLEEP_ITERATION)
					thread_sleep(0);
				
				if(iterations >= YIELD_ITERATION && iterations < MAX_SLEEP_ITERATION)
				{
					iterations = 0;
					thread_sleep(0);
				}
			}
			// Yield processor on multi-processor but if on single processor then give other thread the CPU
			iterations++;
		}				
	}

}

WD_API int spin_lock_trylock(spin_lock_t* spin_lock)
{
    if((*spin_lock)->dest == thread_get_current_id())
		return 0;

    if(OSAtomicCompareAndSwap32(&((*spin_lock)->dest), (*spin_lock)->exchange, (*spin_lock)->compare))
	{
		//assign CurrentThreadId to dest to make it re-entrant safe
		(*spin_lock)->dest = thread_get_current_id();
		// lock acquired 
		return 0;
	}

    return -1;
}

WD_API int spin_lock_unlock(spin_lock_t* spin_lock)
{
    if((*spin_lock)->dest != thread_get_current_id())
        return -1;
    // lock released
    OSAtomicCompareAndSwap32(&((*spin_lock)->dest), (*spin_lock)->compare, thread_get_current_id());	
    return 0;
}

WD_API int semaphore_create(semaphore_t* semaphore, int init_count, int max_count)
{
#if defined LINUX
    if (sem_init(semaphore, 0, init_count) != 0)
    {
        return -1;
    }
#elif defined WIN32
    *semaphore = CreateSemaphore(NULL, init_count, max_count, NULL);
    if (*semaphore == NULL)
    {
        return -1;
    }
#endif
    return 0;
}

WD_API int semaphore_put(semaphore_t* semaphore)
{
#if defined LINUX
    if (sem_post(semaphore) != 0)
    {
        return -1;
    }
#elif defined WIN32
    if (!ReleaseSemaphore(*semaphore, 1, NULL))
    {
        return -1;
    }
#endif
    return 0;
}

WD_API int semaphore_get(semaphore_t* semaphore, uint32 milli_secs)
{
#if defined LINUX

    timeval tv = {0};
    timespec ts = {0};

    gettimeofday(&tv, NULL);
    tv.tv_usec += milli_secs * 1000;
    if ( tv.tv_usec >= 1000000 )
    {
        tv.tv_sec += tv.tv_usec / 1000000;
        tv.tv_usec %= 1000000;
    }
    ts.tv_sec = tv.tv_sec;
    ts.tv_nsec = tv.tv_usec * 1000;

    while (true)
    {
        if (0== sem_timedwait(semaphore,&ts))
            return 1;

        switch(errno)
        {
        case ETIMEDOUT:
            return 0;
        case EINTR:
            continue;
        default:
            return -1;
        }
    }
#elif defined WIN32
    switch (WaitForSingleObject(*semaphore, milli_secs))
    {
    case WAIT_OBJECT_0:
        return 1;
    case WAIT_TIMEOUT:
        return 0;
    default:
        return -1;
    }
#endif
}

WD_API int semaphore_destroy(semaphore_t* semaphore)
{
#if defined LINUX
    sem_destroy(semaphore);
#elif defined WIN32
    CloseHandle(*semaphore);
#endif
    return 0;
}

static unsigned int my_thread(void* pt)
{
    CThread* pThread = (CThread*)pt;
    if ( pThread->OnThreadBegin != NULL )
        pThread->OnThreadBegin();
    uint32 result = pThread->Run();
    if ( pThread->OnThreadEnd != NULL )
        pThread->OnThreadEnd();
    return result;
}

CThread::CThread()
{
    OnThreadBegin = NULL;
    OnThreadEnd = NULL;
}

CThread::~CThread()
{

}

void CThread::StartThread()
{
    thread_create(&m_hThread, my_thread, this);
}

thread_t* CThread::GetHandle()
{
    return &m_hThread;
}

CMutex::CMutex()
{
    {
        int ret = mutex_create(&m_Mutex);
        if ( 0 !=  ret)
            printf( "CMutex()==1 [%u][%s] \r\n", ret, strerror(ret) );
    }
}

CMutex::~CMutex()
{
    mutex_destroy(&m_Mutex);
}

void CMutex::Lock()
{
    mutex_lock(&m_Mutex);
}

void CMutex::UnLock()
{
    mutex_unlock(&m_Mutex);
}

bool CMutex::TryLock()
{
    return mutex_trylock(&m_Mutex) == 0;
}

CSpinLock::CSpinLock()
{
    spin_lock_create(&m_SpinLock);
}

CSpinLock::~CSpinLock()
{
    spin_lock_destroy(&m_SpinLock);
}

void CSpinLock::Lock()
{
    spin_lock_lock(&m_SpinLock);
}

void CSpinLock::UnLock()
{
    spin_lock_unlock(&m_SpinLock);
}

bool CSpinLock::TryLock()
{
    return spin_lock_trylock(&m_SpinLock) == 0;
}

CSemaphore::CSemaphore(int init_count, int max_count)
{
    semaphore_create(&m_Semaphore, init_count, max_count);
}

CSemaphore::~CSemaphore()
{
    semaphore_destroy(&m_Semaphore);
}

int CSemaphore::Put()
{
    return semaphore_put(&m_Semaphore);
}

int CSemaphore::Get(uint32 milli_secs)
{
    return semaphore_get(&m_Semaphore, milli_secs);
}

}
