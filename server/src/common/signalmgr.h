#ifndef _IMMORTAL_COMMON_SIGNAL_MGR_H_
#define _IMMORTAL_COMMON_SIGNAL_MGR_H_

#include "common.h"

#include <setjmp.h>

extern sigjmp_buf g_jmpbuf;
extern bool g_jmpsave;

class CSignalMgr
{
public:
    typedef void(*FCallback)(void);

private:
    FCallback breakdown;            //出错处理函数
    FCallback shutdown;             //退出处理函数
    FCallback custom1;              //自定义处理函数1
    FCallback custom2;              //自定义处理函数2

    std::string local_name;         //本地执行文件名
    std::string core_log_name;      //出错输出 core.log 文件

public:
    CSignalMgr();
    ~CSignalMgr();

    //初始化信号处理
    void Init
    (
        const char* filename,
        CSignalMgr::FCallback breakdown = NULL,
        CSignalMgr::FCallback shutdown = NULL,
        CSignalMgr::FCallback custom1 = NULL,
        CSignalMgr::FCallback custom2 = NULL
    );

    //记录当前 pstack 信息
    bool GenCoreLog(int signo);

    //设置 core.log 输出
    void SetCoreLog( const char* filename );

private:
    //信号注册
    void signal_register(void);

    //数组注册
    void signal_reg_array( int32* array, int32 length, sighandler_t handler );

    //容错处理函数
    static void sig_catch(int signo);

    //错误处理函数
    static void sig_error(int signo);

    //自定义处理函数1
    static void sig_custom1(int signo);

    //自定义处理函数2
    static void sig_custom2(int signo);

    //正常退出处理
    static void sig_exit(int signo);
};
#define theSignalMgr TSignleton< CSignalMgr >::Ref()

#ifdef MISCHANCE_RESUME

#define TRY_MACRO \
    g_jmpsave = true;\
    if ( sigsetjmp( g_jmpbuf, 1 ) == 0 )
#define CATCH_MACRO \
    else
#define END_MACRO \
    g_jmpsave = false;

#else   //#ifdef MISCHANCE_RESUME

#define TRY_MACRO \
    if ( true )
#define CATCH_MACRO \
    if ( false )
#define END_MACRO \
    g_jmpsave = false;

#endif  //#ifdef MISCHANCE_RESUME

#endif

