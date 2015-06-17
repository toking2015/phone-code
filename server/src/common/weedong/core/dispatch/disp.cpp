#include "disp.h"
#include <assert.h>
namespace wd
{

	CCmdDisp::CCmdDisp( DispCmdDeleteFunc_Ptr fn_del, DispCmdErrorFunc_Ptr fn_err /*= NULL*/ )
	{
        m_FuncDeleteHandler = fn_del;
        m_FuncErrorHandler = fn_err;

		m_DispStat			=   DISPSTAT_STOP;
		m_PreCmdHandlerFunc	=	NULL;
		m_PreHandlerParam	=	NULL;

        m_FuncBusyHandler = NULL;
        m_FuncIdleHandler = NULL;
	}

	CCmdDisp::~CCmdDisp()
	{
		StopDisp();

		std::deque< SData >&queue = m_PendingCmd.GetDeque();
		std::deque< SData >::iterator iter = queue.begin();
		while(iter !=  queue.end())
		{
            m_FuncDeleteHandler( iter->data );
			iter++;
		}
		 queue.clear();
	}

	void     CCmdDisp::SetBusyHandlerFunc(BusyHandlerFunc_Ptr pfunc)
    {
        m_FuncBusyHandler = pfunc;
    }

	void     CCmdDisp::SetIdleHandlerFunc(IdleHandlerFunc_Ptr pfunc)
    {
        m_FuncIdleHandler = pfunc;
    }

	void     CCmdDisp::SetPreHandlerFunc(PreCmdHandlerFunc_Ptr pfunc,void*pParam)
	{
		m_PreCmdHandlerFunc	=	pfunc;
		m_PreHandlerParam	=	pParam;
	}

    void     CCmdDisp::SetErrorHandlerFunc(DispCmdErrorFunc_Ptr pfunc)
    {
        m_FuncErrorHandler = pfunc;
    }

	int     CCmdDisp::StartDisp()
	{
		if(m_DispStat != DISPSTAT_STOP)
			return 0;
		m_DispStat  =   DISPSTAT_START;
		if( thread_create(&m_WorkerThread, WorkerProc , this) != 0 )
		{
			m_DispStat  =   DISPSTAT_STOP;
			return 0;
		}
		return 1;
	}

	void    CCmdDisp::StopDisp()
	{
		if(m_DispStat != DISPSTAT_START)
			return;
		m_DispStat  =   DISPSTAT_STOPING;
		thread_wait_exit(&m_WorkerThread);
		//thread_close_handle(&m_WorkerThread);
		m_DispStat  =   DISPSTAT_STOP;
	}

	void     CCmdDisp::RegHandler(uint32 cmdid,DispHandlerFunc_Ptr pFunc,void*pParam)
	{
		if(m_DispStat != DISPSTAT_STOP)
		{
			assert(true);
		}
		CHandlerInfo    info;
		info.m_pFunPtr  =   pFunc;
		info.m_pParam   =   pParam;
		m_HandlerMap.insert(std::pair<uint32,CHandlerInfo>(cmdid,info));
	}

    CHandlerInfo    CCmdDisp::GetHandler( uint32 cmdid )
    {
        std::map< uint32,CHandlerInfo >::iterator iter = m_HandlerMap.find( cmdid );
        if ( iter != m_HandlerMap.end() )
            return iter->second;

        return CHandlerInfo();
    }

	void     CCmdDisp::UnRegHandler(uint32 cmdid)
	{
		if(m_DispStat != DISPSTAT_STOP)
		{
			assert(true);
		}
		m_HandlerMap.erase(cmdid);
	}

	void     CCmdDisp::PushCmd(uint32 cmdid,void* pNetCmd, void* param)
	{
        SData data = { cmdid, pNetCmd, param };
		m_PendingCmd.PushBack( data );
	}

    void    CCmdDisp::SendCmd(uint32 cmdid,void* pNetCmd, void* param)
    {
        SData data = { cmdid, pNetCmd, param };
        m_PendingCmd.PushFront( data );
    }

    uint32  CCmdDisp::GetPendCount(void)
    {
        return m_PendingCmd.Size();
    }

	unsigned int CCmdDisp::WorkerProc(void*param)
	{
		CCmdDisp*pDisp  =   static_cast<CCmdDisp*>(param);
		if(!pDisp)
		{
			thread_exit(0);
			return 0;
		}
		while(pDisp->m_DispStat == DISPSTAT_START)
		{
			SData taskdata;
			if(pDisp->m_PendingCmd.PopFront(taskdata,100) == 0 && taskdata.data)
			{
				std::map<uint32,CHandlerInfo>::iterator iter = pDisp->m_HandlerMap.find(taskdata.id);
				if(iter != pDisp->m_HandlerMap.end())
				{
					if(pDisp->m_PreCmdHandlerFunc)
						pDisp->m_PreCmdHandlerFunc(taskdata.data,pDisp->m_PreHandlerParam, taskdata.param);
					if(iter->second.m_pFunPtr)
						iter->second.m_pFunPtr(taskdata.data,iter->second.m_pParam, taskdata.param);
				}
                else if ( pDisp->m_FuncErrorHandler != NULL )
                    pDisp->m_FuncErrorHandler( taskdata.data, taskdata.param );

                pDisp->m_FuncDeleteHandler( taskdata.data );

                if ( pDisp->m_FuncBusyHandler != NULL )
                    pDisp->m_FuncBusyHandler();
			}
            else
            {
                if ( pDisp->m_FuncIdleHandler != NULL )
                    pDisp->m_FuncIdleHandler();
            }
		}
		thread_exit(0);
		return 0;
	}

}
