#ifndef _COMMON_DC_H_
#define _COMMON_DC_H_

#include "dataproxy.h"

//============================数据中心模板========================
template< class T >
class TDC : public CDataProxy
{
protected:
    T* dc_data;
    std::string dc_name;

public:
    TDC( std::string name ) : dc_name( name )
    {
        dc_data = NULL;
    }

    virtual ~TDC()
    {
        delete dc_data;
    }

    virtual void trans_to_stream( wd::CStream& stream )
    {
        stream << *dc_data;
    }

    virtual void trans_to_db( wd::CStream& stream )
    {
        //创建新对象
        stream >> *dc_data;
    }

public:
    T& db(void)
    {
        if ( dc_data == NULL )
        {
            dc_data = new T;
            CDataProxy::register_module( dc_name, this );
        }
        return *dc_data;
    }
};

namespace dc
{

//==============================安全遍历============================
/*
    array simple:
        void shop_each( SUserShopLog& data )
        safe_each( user->data.shop_log, shop_each );

    indices simple:
        void task_each( std::pair< const uint32, SUserTask >& pair )
        safe_each( user->data.task_map, task_each );

    key simple:
        void var_each( std::pair< const std::string, SUserVar >& pair )
        safe_each( user->data.var_map, var_each );
*/
template< class Tk, class Tv >
struct safe_each_copy_key
{
    uint32 index;
    std::vector< Tk >& k_l;
    safe_each_copy_key( std::vector< Tk >& l ) : index(0), k_l(l){}
    void operator()( std::pair< const Tk, Tv >& node )
    {
        k_l[ index++ ] = node.first;
    }
};
template< class Tc, class Tp >
struct safe_each_map_ele_call
{
    Tc& collect;
    Tp& call;
    safe_each_map_ele_call( Tc& map, Tp& c ) : collect(map), call(c){}

    template< class T > void __call( T iter, T end )
    {
        if ( iter != end )
            call( *iter );
    }

    template< class Tk > void operator()( Tk key )
    {
        __call( collect.find( key ), collect.end() );
    }
};
template< class T, class Tp >
static void safe_each_ele( T iter, T end, Tp call )
{
    for ( ; iter != end; ++iter )
        call( *iter );
}
template< class Tp, class Tv, class Tk >
static void safe_each( std::map< Tk, Tv >& collect, Tp call )
{
    std::vector< Tk > k_l( collect.size() );

    std::for_each( collect.begin(), collect.end(), safe_each_copy_key< Tk, Tv >( k_l ) );
    std::for_each
    (
        k_l.begin(),
        k_l.end(),
        safe_each_map_ele_call< std::map< Tk, Tv >, Tp >( collect, call )
    );
}
template< class Tp, class Tv >
static void safe_each( std::vector< Tv >& collect, Tp call )
{
    for ( int32 i = 0; i < (int32)collect.size(); ++i )
        call( collect[i] );
}

//========================分页返回========================
/*
    simple:
        PQGuildList rep;
        bccopy( rep, msg );

        rep.index = msg.index;
        rep.sum     = dc::cat_elements( guild_list, msg.index, msg.count, rep.list );

        local::write( key, rep );
*/
template< class T1, class T2 >
uint32 cat_elements( T1& src, uint32 index, uint32 count, T2& des )
{
    uint32 sum = src.size();
    if ( index >= sum )
        return 0;

    if ( count > sum - index )
        count = sum - index;

    if ( count <= 0 )
        return 0;

    des.insert( des.end(), src.begin() + index, src.begin() + index + count );

    return sum;
}

//==========================数据检查==========================
/*
    simple:
        if ( map_has_key( user->data.task_map, 1001 ) )
        {
            // do something ...
        }
*/
template< class Tk, class Tv >
bool map_has_key( std::map< Tk, Tv >& map, Tk key )
{
    return ( map.find( key ) != map.end() );
}

} // namespace dc

#endif

