#ifndef _GAMESVR_EVENT_H_
#define _GAMESVR_EVENT_H_

#include "common.h"
#include "proto/user.h"
#include "proto/guild.h"

/************************BEGIN-事件参数************************/
struct SEvent
{
    SUser* user;
    uint32 path;

    SEvent( SUser* u, uint32 p ) : user(u), path(p){}
};

/*
struct SEventSysVarChange : public SEvent
{
    std::string& key;
    SEventSysVarChange( std::string& k ) : key(k){}
};
*/
/************************END-事件参数**************************/

template< typename T >
struct event_each_process
{
    T& data;
    event_each_process( T& d ) : data(d){}

    void operator()( std::pair< std::string, void(*)(T&) > call )
    {
        call.second( data );
    }
};
class CEventMgr
{
private:
    template< typename T >
    std::map< std::string, void(*)(T&) >& switch_event_handler(void)
    {
        static std::map< std::string, void(*)(T&) > handler;
        return handler;
    }

public:
    template< typename T >
    void Listen( const char* name, void(*call)(T&) )
    {
        std::map< std::string, void(*)(T&) >& handler = switch_event_handler<T>();

        handler[ name ] = call;
    }

    template< typename T >
    void Dispatch( T& data )
    {
        std::map< std::string, void(*)(T&) >& handler = switch_event_handler<T>();

        std::for_each( handler.begin(), handler.end(), event_each_process<T>( data ) );
    }
};
#define theEventMgr TSignleton< CEventMgr >::Ref()

template<typename T>
class CEventListen
{
public:
    CEventListen( const char* name, void(&func)(T&) )
    {
        theEventMgr.Listen( name, func );
    }
};

#define EVENT_FUNC( m, s )\
    void m##_event_listen_##s( s& );\
    CEventListen< s >* m##_event_listen_ptr_##s = new ((void*)~0)CEventListen< s >( #m, m##_event_listen_##s );\
    void m##_event_listen_##s( s& ev )

//事件管理器
namespace event
{
    //添加了 dispatch 基本模板, 无特殊需求时不需要手动添加 dispatch 处理流程函数, 直接使用即可
    template< typename T >
    void dispatch( T ev )
    {
        theEventMgr.Dispatch<T>( ev );
    }

}// namespace event

#endif  //IMMORTAL_GAMESVR_EVENTMGR_H_

