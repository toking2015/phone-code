#include "config.h"
#include <json/json.h>
#include <fstream>

namespace config
{

//配置堆
std::vector< SConfig > config_stack;

void load_config_png2jpg( Json::Value& root, SConfig& out )
{
    switch ( root.type() )
    {
    case Json::nullValue:
        break;
    case Json::booleanValue:
        out.png2jpg.used = root.asBool();
        break;
    default:
        {
            out.png2jpg.rgb_quality     = root[ "rgb_quality" ].asInt();
            out.png2jpg.alpha_quality   = root[ "alpha_quality" ].asInt();
            out.png2jpg.used            = true;
        }
        break;
    }
}

void load_config_ignore( Json::Value& root, SConfig& out )
{
    switch ( root.type() )
    {
    case Json::nullValue:
        break;
    default:
        {
            for ( uint32 i = 0; i < root.size(); ++i )
            {
                out.ignore.array.push_back( root[i].asString() );
            }
        }
        break;
    }
}

SConfig load_config( std::string file, SConfig& parent )
{
    //初始化继承
    SConfig ret = parent;

    //忽略列表不作继承
    ret.ignore.array.clear();

    do
    {
        std::ifstream input( file.c_str() );
        if ( !input.is_open() )
            break;

        static Json::Reader reader;

        Json::Value root;
        if ( !reader.parse( input, root ) )
            break;

        //加载 png2jpg 配置
        load_config_png2jpg( root[ "png2jpg" ], ret );

        //加载 ignore 配置
        load_config_ignore( root[ "ignore" ], ret );
    }
    while(0);

    return ret;
}

SConfig setup( int32 depth, std::string& path )
{
    if ( (int32)config_stack.size() <= depth )
        config_stack.resize( depth + 1 );

    //加载父配置
    SConfig parent;
    if ( depth > 0 )
        parent = config_stack[ depth - 1 ];

    //加载配置
    SConfig config = load_config( path + "packet_config", parent );

    //设置配置
    config_stack[ depth ] = config;

    return config;
}

} // namespace config
