#include "common.h"
#include "parammgr.h"

#include "file.h"
#include "config.h"
#include "png2jpg.h"

std::string global_path;

void loop_process( int32 depth, std::string& path, std::set< std::string >& files, std::set< std::string >& dirs )
{
    printf( "scanf: %s\n", path.c_str() );

    SConfig cnf = config::setup( depth, path );

    //去除忽略文件和目录
    for ( std::vector< std::string >::iterator iter = cnf.ignore.array.begin();
        iter != cnf.ignore.array.end();
        ++iter )
    {
        files.erase( *iter );
        dirs.erase( *iter );
    }

    //遍历文件处理列表
    for ( std::set< std::string >::iterator iter = files.begin();
        iter != files.end();
        ++iter )
    {
        uint32 idx = iter->find_last_of( '.' );
        if ( idx <= 0 )
            continue;

        std::string ext = iter->substr( idx + 1 );

        if ( ext == "ExportJson" )
            continue;

        //大写后缀报错
        for ( std::string::iterator i = ext.begin();
            i != ext.end();
            ++i )
        {
            if ( *i >= 'A' && *i <= 'Z' )
            {
                printf( "error ext name: %s\n", ext.c_str() );
                exit(0);
            }
        }

        if ( ext == "png" )
        {
            if ( cnf.png2jpg.used )
            {
                if ( png2jpg::split( path + *iter, cnf.png2jpg.rgb_quality, cnf.png2jpg.alpha_quality ) )
                    printf( "png2jpg: %s\n", iter->c_str() );
            }
        }
    }
}

//运行
void ParamRun( std::vector< std::string > params )
{
    global_path = params[0];
}

int main(int argc, char** argv)
{
    // -p /usr/local/project/phone-code/client/War/image/
    CParamMgr params;
    params.bind( "-p", 1, ParamRun );

    //执行参数
    std::string param_error;
    if ( !params.run( argc, argv, param_error ) )
    {
        printf( param_error.c_str() );
        exit(0);
    }

    file::loop( global_path.c_str(), loop_process );
    return 0;
}

