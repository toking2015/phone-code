#ifndef _COMMON_LUASEQ_H_
#define _COMMON_LUASEQ_H_

extern "C" {
#include "lua.h"
}
#include "common.h"
#include "log.h"
#include "util.h"
/*
    @注册 lua 执行函数
    luaseq::ret( lua对象, 访问路径 ).bind_method( 函数 );
    luaseq::ret( L, "trans.base.foo" ).bind_method( foo );

    @调用 lua 函数
    luaseq::call< 返回类型 >( lua对象, 访问路径 )( 参数1, ...参数5 );
    uint32 value = luaseq::call< uint32 >( L, "trans.base.foo" )( 20, S3UInt32(), "test" );
    luaseq::call( L, "trans.base.foo" )( 20 );
*/

//用于兼容 lua 带返回值函数调用数据返回, 但不应该会真正被执行
/*
template<typename T>
std::stringstream& operator >> ( std::stringstream& stream, T& data )
{
    assert( false );
    return stream;
}
*/
namespace luaseq
{
typedef void(*FToLua)( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
typedef void(*FToStream)( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* map, void* ptr_list );

//< to_stream, to_lua >
typedef std::pair< std::vector< void* >, std::vector< void* > > T_METHOD;
//< member_name, [ method ] >
typedef std::pair< std::string, T_METHOD > T_MEMBER;
//< parent_name, [ member ] >
typedef std::pair< std::string, std::vector< T_MEMBER > > T_DECLARE;
//< struct_name, struct_declare >

std::map< std::string, luaseq::T_DECLARE >& declare_map(void);

std::map< std::string, int32 > push_table_element( lua_State* L, int32 idx );
void pop_table_element( lua_State* L, int32 count );

//=========================================================================
void to_stream( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );
template< typename T >
void to_stream_int( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	T value = T();

	if ( idx != NULL )
		value = lua_tointeger( L, *idx );

	stream << value;
}

template< typename T >
void to_stream_f( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	T value = T();

	if ( idx != NULL )
		value = (T)lua_tonumber( L, *idx );

	stream << value;
}
void to_stream_string( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );
void to_stream_bytes( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );
void to_stream_object( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );
void to_stream_array( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );
void to_stream_indices( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );
void to_stream_map( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list );

//=========================================================================
void to_lua( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_key( lua_State* L, const char* name, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_key( lua_State* L, uint32 index, wd::CStream& stream, uint32& size, void* ptr_list );
template< typename T >
void to_lua_int( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	T value = 0;
	if ( size >= sizeof( T ) )
	{
		stream >> value;
		size -= sizeof( T );
	}
	else
		size = 0;

	lua_pushinteger( L, value );
}
template< typename T >
void to_lua_f( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	T value = 0;
	if ( size >= sizeof( T ) )
	{
		stream >> value;
		size -= sizeof( T );
	}
	else
		size = 0;

	lua_pushnumber( L, value );
}
void to_lua_string( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_bytes( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_object( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_array( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_indices( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );
void to_lua_map( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list );

//================================= c++ object -> lua stack ===============================
#define LUA_PUSH( type, method )\
template<>\
static void __push<type>( lua_State* root, type& value )\
{\
    (method)( root, value );\
}
template<typename P>
static void __push( lua_State* root, P& data )
{
    const char* name = data;

    wd::CStream stream;
    stream << data;
    stream.position(0);

    uint32 size = stream.length();

    lua_newtable( root );
    luaseq::to_lua( root, stream, size, &name );
}

//基本类型处理
LUA_PUSH( bool, lua_pushboolean );
LUA_PUSH( float, lua_pushnumber );
LUA_PUSH( double, lua_pushnumber );
LUA_PUSH( int8, lua_pushinteger );
LUA_PUSH( uint8, lua_pushinteger );
LUA_PUSH( int16, lua_pushinteger );
LUA_PUSH( uint16, lua_pushinteger );
LUA_PUSH( int32, lua_pushinteger );
LUA_PUSH( uint32, lua_pushinteger );
LUA_PUSH( const char*, lua_pushstring );
//字符串类型处理
template<>
static void __push<std::string>( lua_State* root, std::string& value )
{
    lua_pushlstring( root, value.c_str(), value.size() );
}
//容器声明
template<typename P> static void __push( lua_State* root, std::vector<P>& array );
template<typename P> static void __push( lua_State* root, std::map< uint32, P >& indices );
template<typename P> static void __push( lua_State* root, std::map< std::string, P >& map );

//数组参数处理
struct __push_array
{
    lua_State* root;
    int32 count;
    __push_array( lua_State* L ) : root(L), count(0){}

    template<typename E>
    void operator()( E& data )
    {
        lua_pushinteger( root, ++count );
        __push( root, data );
        lua_settable( root, -3 );
    }
};
template<typename P>
static void __push( lua_State* root, std::vector<P>& array )
{
    lua_newtable( root );
    std::for_each( array.begin(), array.end(), __push_array( root ) );
}
//索引参数处理
struct __push_indices
{
    lua_State* root;
    __push_indices( lua_State* L ) : root(L){}

    template<typename E>
    void operator()( E& data )
    {
        lua_pushinteger( root, data.first );
        __push( root, data.second );
        lua_settable( root, -3 );
    }
};
template<typename P>
static void __push( lua_State* root, std::map< uint32, P >& indices )
{
    lua_newtable( root );
    std::for_each( indices.begin(), indices.end(), __push_indices( root ) );
}
//映射参数处理
struct __push_map
{
    lua_State* root;
    __push_map( lua_State* L ) : root(L){}

    template<typename E>
    void operator()( E& data )
    {
        lua_pushlstring( root, data.first.c_str(), data.first.size() );
        __push( root, data.second );
        lua_settable( root, -3 );
    }
};
template<typename P>
static void __push( lua_State* root, std::map< std::string, P >& map )
{
    lua_newtable( root );
    std::for_each( map.begin(), map.end(), __push_map( root ) );
}
#undef LUA_PUSH

//======================= lua stack -> c++ object =========================
#define LUA_FETCH( d, s ) \
template<>\
static void __fetch<d>( lua_State* root, int32 idx, d& data )\
{\
    s src = s();\
    __fetch<s>( root, idx, src );\
    data = (d)src;\
}
template<typename R>
static void __fetch( lua_State* root, int32 idx, R& data )
{
    if ( LUA_TTABLE != lua_type( root, idx ) ) return;

    wd::CStream stream;
    const char* name = data;

    std::map< std::string, int32 > element_indices = luaseq::push_table_element( root, idx );
    luaseq::to_stream( root, stream, &idx, &element_indices, (char**)&name );
    luaseq::pop_table_element( root, element_indices.size() );

    stream.position(0);
    stream >> data;
}
//bool
template<>
static void __fetch<bool>( lua_State* root, int32 idx, bool& data )
{
    if ( LUA_TBOOLEAN != lua_type( root, idx ) ) return;

    data = lua_toboolean( root, idx );
}
//double
template<>
static void __fetch<double>( lua_State* root, int32 idx, double& data )
{
    if ( LUA_TNUMBER != lua_type( root, idx ) ) return;

    data = lua_tonumber( root, idx );
}
//string
template<>
static void __fetch<std::string>( lua_State* root, int32 idx, std::string& data )
{
    if ( LUA_TSTRING != lua_type( root, idx ) ) return;

    data = lua_tostring( root, idx );
}
LUA_FETCH( float, double );
LUA_FETCH( int8, double );
LUA_FETCH( uint8, double );
LUA_FETCH( int16, double );
LUA_FETCH( uint16, double );
LUA_FETCH( int32, double );
LUA_FETCH( uint32, double );
//容器返回声明
template<typename R> static void __fetch( lua_State* root, int32 idx, std::vector<R>& array );
template<typename R> static void __fetch( lua_State* root, int32 idx, std::map< uint32, R >& indices );
template<typename R> static void __fetch( lua_State* root, int32 idx, std::map< std::string, R >& map );
//数组返回处理
template<typename R>
static void __fetch( lua_State* root, int32 idx, std::vector<R>& array )
{
    if ( LUA_TTABLE != lua_type( root, idx ) ) return;

    lua_pushnil( root );
    while( lua_next( root, idx ) != 0 )
    {
        if ( LUA_TNUMBER != lua_type( root, -2 ) )
        {
            lua_pop( root, 1 );
            continue;
        }
        int32 index = lua_tointeger( root, -2 ) - 1;
        if ( index < 0 ) index = 0;

        if ( index >= (int32)array.size() )
            array.resize( index + 1 );
        __fetch( root, lua_gettop( root ), array[ index ] );

        lua_pop( root, 1 );
    }
}
//索引返回处理
template<typename R>
static void __fetch( lua_State* root, int32 idx, std::map< uint32, R >& indices )
{
    if ( LUA_TTABLE != lua_type( root, idx ) ) return;

    lua_pushnil( root );
    while( lua_next( root, idx ) != 0 )
    {
        if ( LUA_TNUMBER != lua_type( root, -2 ) )
        {
            lua_pop( root, 1 );
            continue;
        }

        uint32 index = lua_tointeger( root, -2 );

        __fetch( root, lua_gettop( root ), indices[ index ] );

        lua_pop( root, 1 );
    }
}
//映射返回处理
template<typename R>
static void __fetch( lua_State* root, int32 idx, std::map< std::string, R >& map )
{
    if ( LUA_TTABLE != lua_type( root, idx ) ) return;

    lua_pushnil( root );
    while( lua_next( root, idx ) != 0 )
    {
        std::string key = lua_tostring( root, -2 );

        __fetch( root, lua_gettop( root ), map[ key ] );

        lua_pop( root, 1 );
    }
}
#undef FETCH_COPY

//===============================call==============================
class TCall
{
protected:
    lua_State* root;
    std::string name;
    int32 param_count;
    std::vector< std::string > path;

public:
    TCall( lua_State* L, std::string method );
    virtual ~TCall();

    //对象类型处理
    template<typename P>
    void push( P& data )
    {
        if ( root == NULL )
            return;

        __push( root, data );

        param_count++;
    }

    //执行处理
    void __call(void)
    {
        if ( root == NULL )
            return;

        if ( 0 != lua_pcall( root, param_count, 0, 0 ) )
        {
            LOG_DEBUG( "CLuaFunction.call[%s] Error:%s\n", name.c_str(), lua_tostring( root, -1 ) );

            //path.size() - 1(function) + 1(error string)
            lua_pop( root, path.size() );
            return;
        }

        //path.size() - 1(function)
        lua_pop( root, path.size() - 1 );
        return;
    }

    //参数处理
    void operator()(void)
    {
        __call();
    }
    template<typename P1>
    void operator()( P1 v1 )
    {
        push( v1 );
        __call();
    }
    template<typename P1, typename P2>
    void operator()( P1 v1, P2 v2 )
    {
        push( v1 );
        push( v2 );
        __call();
    }
    template<typename P1, typename P2, typename P3>
    void operator()( P1 v1, P2 v2, P3 v3 )
    {
        push( v1 );
        push( v2 );
        push( v3 );
        __call();
    }
    template<typename P1, typename P2, typename P3, typename P4>
    void operator()( P1 v1, P2 v2, P3 v3, P4 v4 )
    {
        push( v1 );
        push( v2 );
        push( v3 );
        push( v4 );
        __call();
    }
    template<typename P1, typename P2, typename P3, typename P4, typename P5>
    void operator()( P1 v1, P2 v2, P3 v3, P4 v4, P5 v5 )
    {
        push( v1 );
        push( v2 );
        push( v3 );
        push( v4 );
        push( v5 );
        __call();
    }
};

template<typename T>
class TCallExt : public TCall
{
public:
    TCallExt( lua_State* L, std::string method ) : TCall( L, method )
    {
    }

    //执行处理
    bool __call(void)
    {
        if ( root == NULL )
            return false;

        if ( 0 != lua_pcall( root, param_count, 1, 0 ) )
        {
            LOG_DEBUG( "CLuaFunction.call[%s] Error:%s\n", name.c_str(), lua_tostring( root, -1 ) );

            //path.size() - 1(function) + 1(error string)
            lua_pop( root, path.size() );
            return false;
        }

        return true;
    }

    //参数处理
    T operator()(void)
    {
        T data = T();

        if ( __call() )
        {
            __fetch( root, lua_gettop(root), data );
            lua_pop( root, path.size() );
        }

        return data;
    }
    template<typename P1>
    T operator()( P1 v1 )
    {
        T data = T();

        push( v1 );

        if ( __call() )
        {
            __fetch( root, lua_gettop(root), data );
            lua_pop( root, path.size() );
        }

        return data;
    }
    template<typename P1, typename P2>
    T operator()( P1 v1, P2 v2 )
    {
        T data = T();

        push( v1 );
        push( v2 );

        if ( __call() )
        {
            __fetch( root, lua_gettop(root), data );
            lua_pop( root, path.size() );
        }

        return data;
    }
    template<typename P1, typename P2, typename P3>
    T operator()( P1 v1, P2 v2, P3 v3 )
    {
        T data = T();

        push( v1 );
        push( v2 );
        push( v3 );

        if ( __call() )
        {
            __fetch( root, lua_gettop(root), data );
            lua_pop( root, path.size() );
        }

        return data;
    }
    template<typename P1, typename P2, typename P3, typename P4>
    T operator()( P1 v1, P2 v2, P3 v3, P4 v4 )
    {
        T data = T();

        push( v1 );
        push( v2 );
        push( v3 );
        push( v4 );

        if ( __call() )
        {
            __fetch( root, lua_gettop(root), data );
            lua_pop( root, path.size() );
        }

        return data;
    }
    template<typename P1, typename P2, typename P3, typename P4, typename P5>
    T operator()( P1 v1, P2 v2, P3 v3, P4 v4, P5 v5 )
    {
        T data = T();

        push( v1 );
        push( v2 );
        push( v3 );
        push( v4 );
        push( v5 );

        if ( __call() )
        {
            __fetch( root, lua_gettop(root), data );
            lua_pop( root, path.size() );
        }

        return data;
    }
};

template<typename T>
TCallExt<T> call( lua_State* L, std::string method )
{
    return TCallExt<T>( L, method );
}
TCall call( lua_State* L, std::string method );

//===========================================bind=================================
typedef int32(*lua_function)(lua_State*);
//无返回模板
template<typename TF, TF F>
static int32 __addr( lua_State* L )
{
    F();

    return 0;
}
template<typename TF, TF F, typename P1>
static int32 __addr( lua_State* L )
{
    if ( lua_gettop(L) < 1 )
        return 0;

    P1 v1 = P1();
    __fetch( L, 1, v1 );

    F( v1 );

    return 0;
}
template<typename TF, TF F, typename P1, typename P2>
static int32 __addr( lua_State* L )
{
    if ( lua_gettop(L) < 2 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );

    F( v1, v2 );

    return 0;
}
template<typename TF, TF F, typename P1, typename P2, typename P3>
static int32 __addr( lua_State* L )
{
    if ( lua_gettop(L) < 3 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    P3 v3 = P3();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );
    __fetch( L, 3, v3 );

    F( v1, v2, v3 );

    return 0;
}
template<typename TF, TF F, typename P1, typename P2, typename P3, typename P4>
static int32 __addr( lua_State* L )
{
    if ( lua_gettop(L) < 4 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    P3 v3 = P3();
    P4 v4 = P4();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );
    __fetch( L, 3, v3 );
    __fetch( L, 4, v4 );

    F( v1, v2, v3, v4 );

    return 0;
}
template<typename TF, TF F, typename P1, typename P2, typename P3, typename P4, typename P5>
static int32 __addr( lua_State* L )
{
    if ( lua_gettop(L) < 5 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    P3 v3 = P3();
    P4 v4 = P4();
    P5 v5 = P5();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );
    __fetch( L, 3, v3 );
    __fetch( L, 4, v4 );
    __fetch( L, 5, v5 );

    F( v1, v2, v3, v4, v5 );

    return 0;
}
//返回模板
template<typename TF, TF F, typename R>
static int32 __addr_r( lua_State* L )
{
    R ret = F();
    __push( L, ret );

    return 1;
}
template<typename TF, TF F, typename R, typename P1>
static int32 __addr_r( lua_State* L )
{
    if ( lua_gettop(L) < 1 )
        return 0;

    P1 v1 = P1();
    __fetch( L, 1, v1 );

    R ret = F( v1 );
    __push( L, ret );

    return 1;
}
template<typename TF, TF F, typename R, typename P1, typename P2>
static int32 __addr_r( lua_State* L )
{
    if ( lua_gettop(L) < 2 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );

    R ret = F( v1, v2 );
    __push( L, ret );

    return 1;
}
template<typename TF, TF F, typename R, typename P1, typename P2, typename P3>
static int32 __addr_r( lua_State* L )
{
    if ( lua_gettop(L) < 3 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    P3 v3 = P3();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );
    __fetch( L, 3, v3 );

    R ret = F( v1, v2, v3 );
    __push( L, ret );

    return 1;
}
template<typename TF, TF F, typename R, typename P1, typename P2, typename P3, typename P4>
static int32 __addr_r( lua_State* L )
{
    if ( lua_gettop(L) < 4 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    P3 v3 = P3();
    P4 v4 = P4();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );
    __fetch( L, 3, v3 );
    __fetch( L, 4, v4 );

    R ret = F( v1, v2, v3, v4 );
    __push( L, ret );

    return 1;
}
template<typename TF, TF F, typename R, typename P1, typename P2, typename P3, typename P4, typename P5>
static int32 __addr_r( lua_State* L )
{
    if ( lua_gettop(L) < 5 )
        return 0;

    P1 v1 = P1();
    P2 v2 = P2();
    P3 v3 = P3();
    P4 v4 = P4();
    P5 v5 = P5();
    __fetch( L, 1, v1 );
    __fetch( L, 2, v2 );
    __fetch( L, 3, v3 );
    __fetch( L, 4, v4 );
    __fetch( L, 5, v5 );

    R ret = F( v1, v2, v3, v4, v5 );
    __push( L, ret );

    return 1;
}
template<typename TF, TF F>
class __bind
{
public:
    //带返回值
    template<typename R>
    lua_function addr( R(*)() )
    {
        return __addr_r< TF, F, R >;
    }
    template<typename R, typename P1>
    lua_function addr( R(*)(P1) )
    {
        return __addr_r< TF, F, R, P1 >;
    }
    template<typename R, typename P1, typename P2>
    lua_function addr( R(*)(P1, P2) )
    {
        return __addr_r< TF, F, R, P1, P2 >;
    }
    template<typename R, typename P1, typename P2, typename P3>
    lua_function addr( R(*)(P1, P2, P3) )
    {
        return __addr_r< TF, F, R, P1, P2, P3 >;
    }
    template<typename R, typename P1, typename P2, typename P3, typename P4>
    lua_function addr( R(*)(P1, P2, P3, P4) )
    {
        return __addr_r< TF, F, R, P1, P2, P3, P4 >;
    }
    template<typename R, typename P1, typename P2, typename P3, typename P4, typename P5>
    lua_function addr( R(*)(P1, P2, P3, P4, P5) )
    {
        return __addr_r< TF, F, R, P1, P2, P3, P4, P5 >;
    }

    //无返回值
    lua_function addr( void(*)() )
    {
        return __addr< TF, F >;
    }
    template<typename P1>
    lua_function addr( void(*)(P1) )
    {
        return __addr< TF, F, P1 >;
    }
    template<typename P1, typename P2>
    lua_function addr( void(*)(P1, P2) )
    {
        return __addr< TF, F, P1, P2 >;
    }
    template<typename P1, typename P2, typename P3>
    lua_function addr( void(*)(P1, P2, P3) )
    {
        return __addr< TF, F, P1, P2, P3 >;
    }
    template<typename P1, typename P2, typename P3, typename P4>
    lua_function addr( void(*)(P1, P2, P3, P4) )
    {
        return __addr< TF, F, P1, P2, P3, P4 >;
    }
    template<typename P1, typename P2, typename P3, typename P4, typename P5>
    lua_function addr( void(*)(P1, P2, P3, P4, P5) )
    {
        return __addr< TF, F, P1, P2, P3, P4, P5 >;
    }
};

//没有实际作用, 只用默认函数模板
typedef void(*RegDefaultMethodType)(void);
template<typename TF = RegDefaultMethodType>
class TReg
{
private:
    lua_State* root;
    std::string method;

public:
    TReg( lua_State* L, std::string name )
    {
        root = L;
        method = name;
    }

    //根据预先获取的函数类型, 泛化函数地址
    template<TF Address>
    void __bind_method_address(void)
    {
        //展开路径
        std::vector< std::string > path = Split( method, "." );
        int32 index = LUA_GLOBALSINDEX;
        for ( int32 i = 0; i < (int32)path.size() - 1; ++i )
        {
            lua_getfield( root, index, path[i].c_str() );

            //路径结点不存在即创建
            if ( LUA_TTABLE != lua_type( root, -1 ) )
            {
                lua_pop( root, 1 );

                lua_pushlstring( root, path[i].c_str(), path[i].size() );
                lua_newtable( root );
                lua_settable( root, -3 );

                lua_getfield( root, index, path[i].c_str() );
            }

            index = -1;
        }

        std::string& name = path[ path.size() - 1 ];

        //根据不同的泛化函数地址生成对 Address 函数类型 TF 的 lua 标准调用函数实现
        lua_function lua_f = __bind<TF, Address>().addr(Address);

        //绑定 lua->c++ 函数
        lua_pushlstring( root, name.c_str(), name.size() );
        lua_pushcfunction( root, lua_f );
        lua_settable( root, index );

        //弹出参数
        lua_pop( root, path.size() - 1 );
    }

    //获取函数类型, 并创建函数类型模板实例 TReg<Type>
    template<typename Type>
    TReg<Type> __bind_method_type( Type f )
    {
        TReg<Type> reg( root, method );
        return reg;
    }

//需要把外部函数名分别调用 __bind_method_type 和 __bind_method_address
#define bind_method(F)\
    __bind_method_type(F).__bind_method_address<F>()
};
TReg<RegDefaultMethodType> reg( lua_State* L, std::string method );

} // namespace luaseq

#endif

