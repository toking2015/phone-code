#ifndef _IMMORTAL_PUBLIC_SERVER_H_
#define _IMMORTAL_PUBLIC_SERVER_H_

#include "common.h"

namespace server
{

//服务器时间
uint32 local_time( uint32 time = 0 );

//time 时间截最近经过的 6:00 时间( 当天6:00前即返回前一天6:00 ), day == 1 为明天 6:00 时间截, -1为昨天 6:00 时间截
uint32 local_6_time( uint32 time, int32 day = 0 );

//服务器新的一天 每天6点为新的一天
uint32 get_local_sub_day( uint32 time );

//返回服务器变量 key-value 数据
std::map< std::string, std::string >& data_map(void);

//返回合服服务器列表
std::list< int32 >& id_list(void);

//广播 key-value 数据修改
void broadcast_modifity( std::string key, std::string value );

//get
template< typename T >
T get( std::string name )
{
    std::map< std::string, std::string >::iterator iter = data_map().find( name );
    if ( iter == data_map().end() )
        return T();

    std::stringstream stream;
    stream.str( iter->second );

    T value;
    stream >> value;

    return value;
}
template<> std::string get<std::string>( std::string name );
template<> int8 get<int8>( std::string name );
template<> uint8 get<uint8>( std::string name );

//set
template< typename T >
void set( std::string key, T value )
{
    std::stringstream stream;
    stream << value;

    data_map()[ key ] = stream.str();

    //向其它服务器广播变量修改
    broadcast_modifity( key, stream.str() );
}
template<> void set<int8>( std::string key, int8 value );
template<> void set<uint8>( std::string key, uint8 value );

}// namespace server

#endif

