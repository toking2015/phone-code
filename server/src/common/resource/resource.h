#ifndef _IMMORTAL_COMMON_RESOURCE_H_
#define _IMMORTAL_COMMON_RESOURCE_H_

#include "common.h"

//vector 清理
template<typename T>
void resource_clear_vec( T ele )
{
    delete ele;
}
template<typename T>
void resource_clear_list( T ele )
{
    delete ele;
}
template<typename Tx, typename Ty>
void resource_clear_map( std::pair< Tx, Ty > ele )
{
    delete ele.second;
}

template<typename Tx, typename Ty>
void resource_clear_mapvec( std::pair< Tx, std::vector<Ty*> > ele )
{
    std::for_each( ele.second.begin(), ele.second.end(), resource_clear_vec<Ty*> );
}

template<typename Tx, typename Ty, typename Tz>
void resource_clear_mapmap( std::pair< Tx, std::map<Ty, Tz*> > ele )
{
    std::for_each( ele.second.begin(), ele.second.end(), resource_clear_map< Ty, Tz*> );
}

//map 清理
template<typename T>
void resource_clear( std::vector<T*>& data )
{
    std::for_each( data.begin(), data.end(), resource_clear_vec<T*> );
    data.clear();
}

template<typename T>
void resource_clear( std::vector<T>& data )
{
    data.clear();
}

template<typename T>
void resource_clear(  std::list<T*>& data )
{
    std::for_each( data.begin(), data.end(), resource_clear_list<T*> );
    data.clear();
}


template< typename Tx, typename Ty >
void resource_clear( std::map< Tx, Ty >& data )
{
    data.clear();
}

template< typename Tx, typename Ty >
void resource_clear( std::map< Tx, Ty* >& data )
{
    std::for_each( data.begin(), data.end(), resource_clear_map<Tx, Ty*> );
    data.clear();
}

template< typename Tx, typename Ty >
void resource_clear( std::map< Tx, std::vector<Ty*> >& data )
{
    std::for_each( data.begin(), data.end(), resource_clear_mapvec< Tx, Ty > );
    data.clear();
}


template< typename Tx, typename Ty, typename Tz >
void resource_clear( std::map< Tx, std::map< Ty, Tz* > >& data )
{
    std::for_each( data.begin(), data.end(), resource_clear_mapmap< Tx, Ty, Tz > );
    data.clear();
}

//set
template< typename T >
void resource_clear( std::set< T >& data )
{
    data.clear();
}

#endif
