#ifndef _IMMORTAL_COMMON_DYNAMIC_MGR_H_
#define _IMMORTAL_COMMON_DYNAMIC_MGR_H_

#include "common.h"
#include "util.h"
#include <dlfcn.h>

class CDynamicMgr
{
private:
    std::map< std::string, std::pair< std::string, void* > > handle_map;
    std::string local_dir;
    int32 so_index;

public:
    //加载成功后调用
    void(*OnLoaded)(void);

    //御载前调用
    void(*OnUnload)(void);

public:
    CDynamicMgr();

    void config_local_dir( std::string dir );
    void config_so_name( std::string name, std::string file );

    void load( std::string name );
    void close( std::string name );

    template< typename T >
    T get( std::string name, std::string call )
    {
        std::map< std::string, std::pair< std::string, void* > >::iterator iter = handle_map.find( name );
        if ( iter == handle_map.end() )
            return T();

        if ( iter->second.second == NULL )
            return T();

        return (T)dlsym( iter->second.second, call.c_str() );
    }

    void func_reg( std::string name, void** var );
    void func_set( std::string name, void* call );

private:
    std::map< std::string, void** > call_map;
    std::map< std::string, void* > var_map;
};
#define theDynamicMgr TSignleton< CDynamicMgr >::Ref()

#define SO_FUNC_NAME(n) __FILE__ ":" #n

#ifdef BUILDING_DLL //if BUILDING_DLL

#define SO_FUNC_DEC( t, n, ... ) static t n( __VA_ARGS__ );\
static void* var_dy_fn_call_##n;\
struct tag_dy_fn_call_##n;
#define SO_FUNC_REL( t, n, ... ) \
struct SO_HEAD::tag_dy_fn_call_##n\
{\
    tag_dy_fn_call_##n(){ theDynamicMgr.func_set( SO_FUNC_NAME(n), (void*)( SO_HEAD::n ) ); }\
};\
void* SO_HEAD::var_dy_fn_call_##n = new ((void*)~0)SO_HEAD::tag_dy_fn_call_##n;\
t SO_HEAD::n( __VA_ARGS__ )

#else //ifdef BUILDING_DLL

#define SO_FUNC_DEC( t, n, ... ) typedef t(*_F##n)( __VA_ARGS__ );\
static _F##n n;\
static t disuse_##n( __VA_ARGS__ );\
static _F##n func_dy_fn_var_##n(void);

#define SO_FUNC_REL( t, n, ... ) \
SO_HEAD::_F##n SO_HEAD::func_dy_fn_var_##n(void)\
{\
    theDynamicMgr.func_reg( SO_FUNC_NAME(n), (void**)&(SO_HEAD::n) );\
    return NULL;\
}\
SO_HEAD::_F##n SO_HEAD::n = SO_HEAD::func_dy_fn_var_##n();\
t SO_HEAD::disuse_##n( __VA_ARGS__ )

#endif //end BUILDING_DLL

#endif

