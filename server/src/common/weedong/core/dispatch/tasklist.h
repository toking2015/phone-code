/*************************************************
  Model:             任务队列
  Author:            闾训杰
  Date:              2011-11-15
  Descript:          提供一个可等待的消息队列实现,方便上层应用
*************************************************/

#ifndef _WEEDONG_CORE_TASKLIST_H_
#define _WEEDONG_CORE_TASKLIST_H_

#include <queue>
#include "../os.h"

namespace wd
{

template<class TypeValue>
class CTaskList
{
public:
	CTaskList(void);
	~CTaskList(void);

    /*************************************************
      Description:    // 投递一个任务到队列前面
      Input:          //  v 投递的任务
      Output:         //
      Return:         //
      Others:         //
    *************************************************/
	void		PushFront(TypeValue& v);

    /*************************************************
      Description:    // 投递一个任务到队列后面
      Input:          //  v 投递的任务
      Output:         //
      Return:         //
      Others:         //
    *************************************************/
	void		PushBack(TypeValue& v);

    /*************************************************
      Description:    // 从队列前面取出一个任务
      Input:          // v 要取出的任务 timeout 等待的毫秒数
      Output:         //
      Return:         // 返回0表示获得了一个任务 返回-1表示没有获得任务
      Others:         //
    *************************************************/
	int			PopFront(TypeValue&v , uint32 timeout);

    /*************************************************
      Description:    // 从队列后面取出一个任务
      Input:          // v 要取出的任务 timeout 等待的毫秒数
      Output:         //
      Return:         // 返回0表示获得了一个任务 返回-1表示没有获得任务
      Others:         //
    *************************************************/
	int			PopBack(TypeValue&v , uint32 timeout);

    /*************************************************
      Description:    // 锁定队列，提供一个手工操作队列的方式
      Input:          //
      Output:         //
      Return:         //
      Others:         //
    *************************************************/
	void		Lock();

    /*************************************************
      Description:    // 解锁队列，提供一个手工操作队列的方式
      Input:          //
      Output:         //
      Return:         //
      Others:         //
    *************************************************/
	void		UnLock();

    /*************************************************
      Description:    // 获得队列中任务的数量
      Input:          //
      Output:         //
      Return:         //
      Others:         //
    *************************************************/
	int			Size();

    /*************************************************
      Description:    // 获得任务队列
      Input:          //
      Output:         //
      Return:         //
      Others:         //
    *************************************************/
	std::deque<TypeValue>&GetDeque(){ return m_deque;}
protected:
	std::deque<TypeValue>	    m_deque;
	semaphore_t				    m_sem;
	mutex_t 					m_mutex;
};


template<class TypeValue>
CTaskList<TypeValue>::CTaskList(void)
{
    mutex_create(&m_mutex);
    semaphore_create(&m_sem,0,0x0FFFFFFF);
}

template<class TypeValue>
CTaskList<TypeValue>::~CTaskList(void)
{
    mutex_destroy(&m_mutex);
    semaphore_destroy(&m_sem);
}

template<class TypeValue>
void		CTaskList<TypeValue>::PushFront(TypeValue& v)
{
    mutex_lock(&m_mutex);
	m_deque.push_front(v);
	mutex_unlock(&m_mutex);
	semaphore_put(&m_sem);
}

template<class TypeValue>
void		CTaskList<TypeValue>::PushBack(TypeValue& v)
{
    mutex_lock(&m_mutex);
	m_deque.push_back(v);
	mutex_unlock(&m_mutex);
	semaphore_put(&m_sem);
}

template<class TypeValue>
int		CTaskList<TypeValue>::PopFront(TypeValue& v , uint32 timeout)
{
    if(semaphore_get(&m_sem,timeout) == 1 )
    {
        mutex_lock(&m_mutex);
        v	=	m_deque.front();
        m_deque.pop_front();
        mutex_unlock(&m_mutex);
        return 0;
    }
    return -1;
}

template<class TypeValue>
int		CTaskList<TypeValue>::PopBack(TypeValue& v , uint32 timeout)
{
    if(semaphore_get(&m_sem,timeout) == 1 )
    {
        mutex_lock(&m_mutex);
        v = m_deque.back();
        m_deque.PopBack();
        mutex_unlock(&m_mutex);
        return 0;
    }
    return -1;
}

template<class TypeValue>
int			CTaskList<TypeValue>::Size()
{
	int size = 0;
	mutex_lock(&m_mutex);
	size	=	(int)m_deque.size();
    mutex_unlock(&m_mutex);
	return size;
}

}

#endif
