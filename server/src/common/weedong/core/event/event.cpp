#include "event.h"

namespace wd
{

CEventMgr::CEventMgr(int nMaxEvent)
{
    m_EventList.resize(nMaxEvent);
}

CEventMgr::~CEventMgr()
{

}

int CEventMgr::Register(int nEventID, EVENT_PROC_T fn)
{
    if ((uint32)nEventID >= m_EventList.size())
    {
        return 0;
    }

    int nMaxID = 0;
    for (uint32 i=0; i<m_EventList[nEventID].size(); i++)
    {
        int nCurID = (m_EventList[nEventID])[i].first;
        if (nCurID > nMaxID)
        {
            nMaxID = nCurID;
        }
    }
    nMaxID++;

    m_EventList[nEventID].push_back(std::make_pair(nMaxID, fn));
    
    nMaxID ^= (nEventID << 16);
    return nMaxID;
}

int	CEventMgr::UnRegister(int nRegisterID)
{
    int nEventType = nRegisterID >> 16;
    int nEventID = (nRegisterID & 0xffff);

    if ((uint32)nEventType >= m_EventList.size())
    {
        return 0;
    }

    for (uint32 i=0; i<m_EventList[nEventType].size(); i++)
    {
        int nCurID = (m_EventList[nEventType])[i].first;
        if (nCurID == nEventID)
        {
            (m_EventList[nEventType])[i] = (m_EventList[nEventType])[m_EventList[nEventType].size()-1];
            (m_EventList[nEventType]).pop_back();
            return 1;
        }
    }

    return 0;
}

int	CEventMgr::Dispatch(int nEventID, EventBase* pEvent)
{
    if ((uint32)nEventID >= m_EventList.size())
    {
        return 0;
    }

    std::vector< std::pair<int, EVENT_PROC_T> > vecEvent = m_EventList[nEventID];   // 防止在回调接口内有注册和取消注册调用
    for (uint32 i=0; i<vecEvent.size(); i++)
    {
        vecEvent[i].second(pEvent);
    }

    return 1;
}

}