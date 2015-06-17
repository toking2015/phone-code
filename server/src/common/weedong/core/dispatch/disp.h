/*************************************************
  Model:             消息分派器
  Author:            闾训杰
  Date:              2011-11-15
  Descript:          消息分派器提供一个命令消息到处理函数的关系绑定分派功能
*************************************************/

#ifndef _WEEDONG_CORE_DISP_H_
#define _WEEDONG_CORE_DISP_H_

#include "../os.h"
#include "tasklist.h"
#include <map>
#include <list>

namespace wd
{
	//分派器的状态
	enum{
		DISPSTAT_STOP = 0,      //已经停止状态
		DISPSTAT_STOPING,       //正在停止中得状态
		DISPSTAT_START          //正常启动状态
	};

	//定义命令预处理函数类型
	typedef void (*PreCmdHandlerFunc_Ptr)(void* pNetCmd, void* pStatic, void* pDynamic);

	//定义命令处理函数类型
	typedef void (*DispHandlerFunc_Ptr)(void* pNetCmd, void* pStatic, void* pDynamic);

    //定义命令销毁函数类型
    typedef void (*DispCmdDeleteFunc_Ptr)(void* pNetCmd);

    //定义错误命令回调函数类型
    typedef void (*DispCmdErrorFunc_Ptr)(void* pNetCmd, void*pDynamic );

    //定义任务处理完的回调函数类型
    typedef void (*BusyHandlerFunc_Ptr)(void);

    //定义无任务处理的闲置回调函数类型
    typedef void (*IdleHandlerFunc_Ptr)(void);

	//记录消息处理函数和参数的内部结构
	class CHandlerInfo{
	public:
		CHandlerInfo()
		{
			m_pFunPtr	=	NULL;
			m_pParam	=	NULL;
		}

		~CHandlerInfo()
		{
		}

		DispHandlerFunc_Ptr	    m_pFunPtr;
		void*                   m_pParam;
	};

	//定义分派器类
	class CCmdDisp{
    public:
        struct SData
        {
            uint32 id;
            void*  data;
            void*  param;
        };
	public:
		CCmdDisp( DispCmdDeleteFunc_Ptr fn_del, DispCmdErrorFunc_Ptr fn_err = NULL );
		virtual ~CCmdDisp();

        /*************************************************
		  Description:    // 设置当前消息队列处理完后的回调函数
		*************************************************/
		void     SetBusyHandlerFunc(BusyHandlerFunc_Ptr pfunc);

        /*************************************************
		  Description:    // 设置无消息闲置回调函数
		*************************************************/
		void     SetIdleHandlerFunc(IdleHandlerFunc_Ptr pfunc);

		/*************************************************
		  Description:    // 设置消息预处理回调函数
		  Input:          //
		  Output:         //
		  Return:         //
		  Others:         //
		*************************************************/
		void     SetPreHandlerFunc(PreCmdHandlerFunc_Ptr pfunc,void*pParam);

        /*************************************************
		  Description:    // 设置错误消息回调函数
		  Input:          //
		  Output:         //
		  Return:         //
		  Others:         //
		*************************************************/
		void     SetErrorHandlerFunc(DispCmdErrorFunc_Ptr pfunc);

		/*************************************************
		  Description:    // 启动分派器类
		  Input:          //
		  Output:         //
		  Return:         // 启动成功返回1 ，失败返回0
		  Others:         //
		*************************************************/
		int     StartDisp();

		/*************************************************
		  Description:    // 停止分派器类
		  Input:          //
		  Output:         //
		  Return:         //
		  Others:         //
		*************************************************/
		void    StopDisp();

		/*************************************************
		  Description:    // 注册消息处理函数，该函数不支持多线程，所以要在StartDisp调用之前调用
		  Input:          // cmdid 消息ID , pFunc 处理函数 , pParam 用户定义参数
		  Output:         //
		  Return:         //
		  Others:         //
		*************************************************/
		void    RegHandler(uint32 cmdid,DispHandlerFunc_Ptr pFunc,void*pParam);

		/*************************************************
		  Description:    // 获取注册的消息处理函数
		  Input:          // cmdid 消息ID
		  Output:         //
		  Return:         // 返回注册函数
		  Others:         //
		*************************************************/
		CHandlerInfo    GetHandler( uint32 cmdid );

		/*************************************************
		  Description:    // 反注册消息处理函数，该函数不支持多线程，所以要在StartDisp调用之前调用
		  Input:          // cmdid 消息ID
		  Output:         //
		  Return:         //
		  Others:         //
		*************************************************/
		void    UnRegHandler(uint32 cmdid);

		/*************************************************
		  Description:    // 压入消息进行处理
		  Input:          // cmdid消息ID ， pNetCmd 消息指针，该消息将会被分派器释放
		  Output:         //
		  Return:         //
		  Others:         //
		*************************************************/
		void    PushCmd(uint32 cmdid,void* pNetCmd, void* param);
        void    SendCmd(uint32 cmdid,void* pNetCmd, void* param);

        uint32  GetPendCount(void);

	protected:
		static unsigned int WorkerProc(void*param);

	protected:
		int										m_DispStat;				//分派器状态
		thread_t								m_WorkerThread;			//工作线程
		std::map< uint32,CHandlerInfo >			m_HandlerMap;			//已经注册好的处理器
		CTaskList< SData >	                    m_PendingCmd;			//任务列表
		PreCmdHandlerFunc_Ptr					m_PreCmdHandlerFunc;	//命令预处理函数
		void*									m_PreHandlerParam;		//命令预处理参数
        DispCmdDeleteFunc_Ptr                   m_FuncDeleteHandler;    //命令销毁函数
        DispCmdErrorFunc_Ptr                    m_FuncErrorHandler;     //命令错误函数
        BusyHandlerFunc_Ptr                     m_FuncBusyHandler;      //当前列表消息处理完后回调
        IdleHandlerFunc_Ptr                     m_FuncIdleHandler;      //无消息处理闲置后回调
	};

}

#endif
