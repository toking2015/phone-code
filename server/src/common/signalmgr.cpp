#include "signalmgr.h"
#include "misc.h"

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/syscall.h>

jmp_buf g_jmpbuf;
bool g_jmpsave = false;

CSignalMgr::CSignalMgr()
{
}

CSignalMgr::~CSignalMgr()
{
}

//初始化信号处理
void CSignalMgr::Init
(
    const char* filename,
    CSignalMgr::FCallback fbreak/* = NULL*/,
    CSignalMgr::FCallback fshut/* = NULL*/,
    CSignalMgr::FCallback fcustom1/* = NULL*/,
    CSignalMgr::FCallback fcustom2/* = NULL*/
)
{
    breakdown = fbreak;
    shutdown = fshut;
    custom1 = fcustom1;
    custom2 = fcustom2;

    local_name = filename;

    signal_register();
}

//设置 core.log 输出
void CSignalMgr::SetCoreLog( const char* filename )
{
    core_log_name = filename;
}

//生成堆栈地址, 不输出地址对应文件行, 如需要使用 ./control core 命令可对 core.log 进行解释生成代码行记录
bool CSignalMgr::GenCoreLog(int signo)
{
    if ( core_log_name.empty() )
        return false;

    int64 tid = (int64)syscall(SYS_gettid);

    //char* sed_string = "sed '1,8d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d'";
    const char* sed_string = "sed '1,8d'";

    local_execute( "date > %s.date", core_log_name.c_str() );
    local_execute( "pstack %lu | %s > %s.stack",
        tid,
        sed_string,
        core_log_name.c_str() );
    local_execute( "cat %s %s.date %s.stack > %s.out",
        core_log_name.c_str(),
        core_log_name.c_str(),
        core_log_name.c_str(),
        core_log_name.c_str() );
    local_execute( "rm -f %s %s.date %s.stack",
        core_log_name.c_str(),
        core_log_name.c_str(),
        core_log_name.c_str() );
    local_execute( "mv %s.out %s", core_log_name.c_str(), core_log_name.c_str() );

    return true;
}

//信号注册
void CSignalMgr::signal_register(void)
{
    //忽略信号
    int32 signal_ignore[] =
    {
        SIGIO/*异步IO*/,
        SIGPIPE/*管道出错*/,
        SIGPOLL/*异步IO*/,
        SIGPROF/*setitimer到期*/,
        SIGURG/*紧急事件,如网络带外数据*/,
        SIGVTALRM/*setitimer产生*/,
        SIGCHLD/*子进程终止*/,
        SIGCONT/*停止的进程继续执行*/,
        SIGHUP/*终端关闭*/,
    };

    //容错信号
    int32 signal_catch[] =
    {
        SIGABRT/*abort(),内部调用*/,
        SIGILL/*SIGILL,代码非法指令*/,
        SIGSEGV/*内存非法访问*/,
        SIGFPE/*算术运算异常*/,
    };

    //错误信号
    int32 signal_error[] =
    {
        SIGALRM/*系统警告*/,
        SIGBUS/*总线错误*/,
        SIGPWR/*Ups电源切换*/,
        SIGSYS/*系统调用错误*/
    };

    //自定义信号
    int32 signal_custom1[] =
    {
        SIGUSR1/*自定义信号1*/,
    };

    //正常关闭信号
    int32 signal_custom2[] =
    {
        SIGUSR2/*自定义信号2*/,
    };

    //暂不使用
    //int32 signal_nouse[] =
    //{
    //    SIGINT/*ctrl+c,外部调用*/,
    //    SIGKILL/*kill,外部调用*/,
    //    SIGQUIT/*ctrl+\,外部调用*/,
    //    SIGSTOP/*进程终止*/,
    //    SIGTERM/*kill(),内部调用*/,
    //    SIGTRAP/*调试器切入(gdb)*/,
    //    SIGTSTP/*ctrl+z,外部挂起*/,
    //    SIGTTIN/*终端读取*/,
    //    SIGTTOU/*终端输出*/,
    //};

    signal_reg_array( signal_ignore, sizeof( signal_ignore ) / sizeof( int32 ), SIG_IGN );
    signal_reg_array( signal_catch, sizeof( signal_catch ) / sizeof( int32 ), sig_catch );
    signal_reg_array( signal_error, sizeof( signal_error ) / sizeof( int32 ), sig_error );
    signal_reg_array( signal_custom1, sizeof( signal_custom1 ) / sizeof( int32 ), sig_custom1 );
    signal_reg_array( signal_custom2, sizeof( signal_custom2 ) / sizeof( int32 ), sig_custom2 );

    //忽略信号使用block, 进程不再接受相关信号处理(不会被中断)
    sigset_t signal_mask;
    sigemptyset( &signal_mask );
    for ( int32 i = 0; i < (int32)( sizeof( signal_ignore ) / sizeof( int32 ) ); ++i )
        sigaddset( &signal_mask, signal_ignore[i] );
    if ( sigprocmask( SIG_BLOCK, &signal_mask, NULL ) != 0 )
        printf( "%s:%u sigprocmask error!", __FILE__, __LINE__ );
}

//数组注册
void CSignalMgr::signal_reg_array( int32* array, int32 length, sighandler_t handler )
{
    for ( int i=0; i<length; ++i )
        signal( array[i], handler );
}

//容错处理函数
void CSignalMgr::sig_catch(int signo)
{
    //置换处理函数
    /*sighandler_t handler = */signal( signo, sig_error );

    //没有记录长跳点
    if ( !g_jmpsave )
    {
        CSignalMgr::sig_error( signo );
        return;
    }

    //生成记录
    if ( !theSignalMgr.GenCoreLog( signo ) )
    {
        //CSignalMgr::sig_error( signo );
        //return;
    }

    //置换处理函数
    //signal( signo, handler );
    signal( signo, sig_catch );

    //长跳转
    g_jmpsave = false;
    siglongjmp( g_jmpbuf, signo );
}

//错误处理函数
void CSignalMgr::sig_error(int signo)
{
    if ( theSignalMgr.breakdown != NULL )
        theSignalMgr.breakdown();

    signal(SIGABRT, SIG_DFL);
    abort();    //产生 SIGABRT 信号
}

//自定义行为1
void CSignalMgr::sig_custom1(int signo)
{
    if ( theSignalMgr.custom1 != NULL )
        theSignalMgr.custom1();
}

//自定义行为2
void CSignalMgr::sig_custom2(int signo)
{
    if ( theSignalMgr.custom2 != NULL )
        theSignalMgr.custom2();
}

//关闭服务器
void CSignalMgr::sig_exit(int signo)
{
    if ( theSignalMgr.shutdown != NULL )
        theSignalMgr.shutdown();

    exit(0);
}

