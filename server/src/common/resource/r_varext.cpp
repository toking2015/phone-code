#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_varext.h"

CVarExt::~CVarExt()
{
    ClearData();
}

void CVarExt::LoadData(void)
{
    //清空数据
    ClearData();

    //父类加载数据
    CVarData::LoadData();

    //分析匹配key
    for ( CVarData::UInt32VarMap::iterator iter = id_var_map.begin();
        iter != id_var_map.end();
        ++iter )
    {
        int32 count = 0;

        std::string key = iter->first;
        for ( std::string::iterator i = key.begin();
            i != key.end();
            ++i )
        {
            if ( *i == '%' )
                ++count;
        }

        //参数匹配最大限制 5 个
        if ( count == 0 || count > 5 )
            continue;

        match_var_map[ count ][ iter->first ] = iter->second;
    }

    //清空匹配key
    for ( std::map< int32, std::map< std::string, SData* > >::iterator i = match_var_map.begin();
        i != match_var_map.end();
        ++i )
    {
        for ( std::map< std::string, SData* >::iterator j = i->second.begin();
            j != i->second.end();
            ++j )
        {
            id_var_map.erase( j->first );
        }
    }
}
void CVarExt::ClearData(void)
{
    /*
    for ( std::map< int32, std::map< std::string, SData* > >::iterator i = match_var_map.begin();
        i != match_var_map.end();
        ++i )
    {
        for ( std::map< std::string, SData* >::iterator j = i->second.begin();
            j != i->second.end();
            ++j )
        {
            delete j->second;
        }
    }
    */
    match_var_map.clear();
}

CVarData::SData* CVarExt::Find( std::string key )
{
    CVarData::UInt32VarMap::iterator iter = id_var_map.find( key );
    if ( id_var_map.end() != iter )
        return iter->second;

    //深度匹配, 右匹配, 先从最多参数 key 开始匹配, 避免少参数 key 模糊匹配成功
    for ( std::map< int32, std::map< std::string, SData* > >::reverse_iterator i = match_var_map.rbegin();
        i != match_var_map.rend();
        ++i )
    {
        for ( std::map< std::string, SData* >::iterator j = i->second.begin();
            j != i->second.end();
            ++j )
        {
            int32 v1 = 0, v2 = 0, v3 = 0, v4 = 0, v5 = 0, pc = 0;

            switch ( i->first )
            {
            case 1:
                pc = sscanf( key.c_str(), j->first.c_str(), &v1 );
                break;
            case 2:
                pc = sscanf( key.c_str(), j->first.c_str(), &v1, &v2 );
                break;
            case 3:
                pc = sscanf( key.c_str(), j->first.c_str(), &v1, &v2, &v3 );
                break;
            case 4:
                pc = sscanf( key.c_str(), j->first.c_str(), &v1, &v2, &v3, &v4 );
                break;
            case 5:
                pc = sscanf( key.c_str(), j->first.c_str(), &v1, &v2, &v3, &v4, &v5 );
                break;
            }

            //匹配成功
            if ( pc == i->first )
                return j->second;
        }
    }

    return NULL;
}

