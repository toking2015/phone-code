#ifndef _WEEDONG_CORE_EVENTMGR_H_
#define _WEEDONG_CORE_EVENTMGR_H_

#include "../os.h"
#include <vector>

namespace wd
{

class CEventMgr
{
public:
    typedef struct _EventBase
    {
        int nEventID;
        int nSource;
        int nTarget;
    } EventBase;

    // 事件回调函数原型
    typedef void (*EVENT_PROC_T)(EventBase*);

public:
    CEventMgr(int nMaxEvent);
    ~CEventMgr();

    /*************************************************
      Description:    // 注册一个事件
      Input:          // nEventID 事件ID
                      // fn 事件回调函数
      Output:         // 0 失败 非零 注册ID
      Return:         // 
      Others:         // 
    *************************************************/
    int Register(int nEventID, EVENT_PROC_T fn);

    /*************************************************
      Description:    // 取消事件注册
      Input:          // nRegisterID 注册ID
      Output:         // 0 失败 1 成功
      Return:         // 
      Others:         // 
    *************************************************/
    int	UnRegister(int nRegisterID);

    /*************************************************
      Description:    // 激活事件
      Input:          // nEventID 事件ID
                      // pEvent 事件信息指针
      Output:         // 0 失败 1 成功
      Return:         // 
      Others:         // 
    *************************************************/
    int	Dispatch(int nEventID, EventBase* pEvent);

private:
    std::vector< std::vector< std::pair<int, EVENT_PROC_T> > > m_EventList;
};

}

#endif
