#ifndef IMMORTAL_COMMON_RESOURCE_R_GLOBALEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_GLOBALEXT_H_

#include "r_globaldata.h"
#include "util.h"

//基本模板
template< typename T >
static T& global_get_cache( CGlobalData* base, std::map< std::string, T >& cache, std::string& name )
{
    if ( cache.find( name ) == cache.end() )
    {
        T& value = cache[ name ];

        CGlobalData::SData* data = base->Find( name );
        if ( data != NULL )
        {
            std::stringstream stream( data->data );
            stream >> value;
        }

        return value;
    }

    return cache[ name ];
}

//字符串模板
template<>
static std::string& global_get_cache<std::string>
( CGlobalData* base, std::map< std::string, std::string >& cache, std::string& name )
{
    CGlobalData::SData* data = base->Find( name );
    if ( data != NULL )
        return data->data;

    static std::string empty_string;
    return empty_string;
}

//array< uint32 >
template<>
static std::vector< uint32 >& global_get_cache< std::vector< uint32 > >
( CGlobalData* base, std::map< std::string, std::vector< uint32 > >& cache, std::string& name )
{
    std::map< std::string, std::vector< uint32 > >::iterator i = cache.find( name );
    if ( i == cache.end() )
    {
        std::vector< uint32 >& ret = cache[ name ];

        CGlobalData::SData* data = base->Find( name );
        if ( data != NULL )
        {
            Tokens value_list = Split( data->data, "," );
            for ( Tokens::iterator iter = value_list.begin();
                iter != value_list.end();
                ++iter )
            {
                ret.push_back( str2int( iter->c_str() ) );
            }
        }

        return ret;
    }

    return i->second;
}

//S3UInt32
template<>
static S3UInt32& global_get_cache< S3UInt32 >
( CGlobalData* base, std::map< std::string, S3UInt32 >& cache, std::string& name )
{
    std::map< std::string, S3UInt32 >::iterator i = cache.find( name );
    if ( i == cache.end() )
    {
        S3UInt32& ret= cache[ name ];

        CGlobalData::SData* data = base->Find( name );
        if ( data != NULL )
            sscanf( data->data.c_str(), "%u%%%u%%%u", &ret.cate, &ret.objid, &ret.val );

        return ret;
    }

    return i->second;
}

class CGlobalExt : public CGlobalData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32GlobalMap::iterator iter = id_global_map.begin();
            iter != id_global_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    bool HasEspecial( std::string& text );

private:
    //用于不同数据类型的 cache
    template< typename T >
    std::map< std::string, T >& cache_map(void)
    {
        static std::map< std::string, T > map;

        return map;
    }

public:
    template< typename T >
    T& get( std::string name )
    {
        return global_get_cache<T>( this, cache_map<T>(), name );
    }
};
#define theGlobalExt TSignleton<CGlobalExt>::Ref()

#endif

