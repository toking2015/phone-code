#include "png2jpg.h"
#include "file.h"

namespace png2jpg
{

bool split( std::string file, uint32 rgb_quality, uint32 alpha_quality )
{
    //文件名分析
    uint32 idx = (uint32)file.find_last_of( '/' );

    std::string path    = file.substr( 0, idx + 1 );
    std::string name    = file.substr( idx + 1 );
    name = name.substr( 0, name.find_last_of( '.' ) );

    std::string jpg_name = path + name + ".jpg";
    std::string awp_name = path + name + ".awp";

    //获取 png 文件大小
    uint32 size = file::get_size( file );

    //小于 100k 的文件不作处理
    if ( size <= 100 * 1024 )
    {
        file::del( jpg_name );
        file::del( awp_name );
        return false;
    }

    //加载 png 数据
    bool ret = false;
    do
    {
        image::SImage image;
        if ( !image::load_png( file, image ) )
        {
            printf( "png2jpg: load png file error[%s]\n", file.c_str() );
            break;
        }

        //保存RGB
        if ( !image::save_jpg( jpg_name, image, rgb_quality ) )
        {
            printf( "png2jpg: save jpg file error[%s]\n", jpg_name.c_str() );
            break;
        }

        //修改 alpha channel
        for ( int32 i = 0, count = image.width * image.height * 4; i < count; i += 4 )
        {
            char alpha = image.data[ i + 3 ];

            image.data[ i + 0 ] = alpha;
            image.data[ i + 1 ] = alpha;
            image.data[ i + 2 ] = alpha;
        }

        //保存A
        if ( !image::save_jpg( awp_name, image, alpha_quality ) )
        {
            printf( "png2jpg: save awp file error[%s]\n", awp_name.c_str() );
            break;
        }

        ret = true;
    }
    while(0);

    if ( ret == false )
    {
        file::del( jpg_name );
        file::del( awp_name );
    }
    else
    {
        file::del( file );
    }

    return true;
}

} // namespace png2jpg

