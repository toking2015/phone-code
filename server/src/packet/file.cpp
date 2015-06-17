#include "file.h"

#include <dirent.h>
#include <fstream>

namespace file
{

void loop( std::string path, FCall call, int32 depth/* = 0 */ )
{
    if ( path.empty() || *path.rbegin() != '/' )
        return;

    DIR* dir = opendir( path.c_str() );
    if ( dir == NULL )
        return;

    //先找出文件夹内容
    std::set< std::string > files;
    std::set< std::string > dirs;
    for ( dirent* ent = readdir( dir ); ent != NULL; ent = readdir( dir ) )
    {
        if ( ent->d_name[0] == '.' )
            continue;

        if ( ent->d_type & DT_DIR )
            dirs.insert( ent->d_name );
        else
            files.insert( ent->d_name );
    }

    call( depth, path, files, dirs );

    //递归
    for ( std::set< std::string >::iterator iter = dirs.begin();
        iter != dirs.end();
        ++iter )
    {
        loop( path + *iter + "/", call, depth + 1 );
    }
}

uint32 get_size( std::string& file )
{
    //读取 png 文件数据
    std::ifstream in( file.c_str(), std::ios_base::in | std::ios_base::binary );
    if ( !in.is_open() )
    {
        printf( "file: can't open file to get_size\n" );
        return 0;
    }

    in.seekg( 0, std::ios_base::end );
    uint32 size = (uint32)in.tellg();
    in.close();

    return size;
}

void del( std::string& file )
{
    unlink( file.c_str() );
}

bool read( std::string& file, std::vector<char>& data )
{
    //读取 png 文件数据
    std::ifstream in( file.c_str(), std::ios_base::in | std::ios_base::binary );
    if ( !in.is_open() )
    {
        printf( "file: can't open file to read\n" );
        return false;
    }

    in.seekg( 0, std::ios_base::end );
    uint32 size = (uint32)in.tellg();
    in.seekg( 0, std::ios_base::beg );

    if ( size <= 0 )
    {
        printf( "file: file size == 0\n" );
        return false;
    }

    data.resize( size );

    in.read( &data[0], data.size() );
    in.close();

    return true;
}

bool write( std::string& file, std::vector<char>& data )
{
    if ( data.empty() )
    {
        printf( "file: can't write a empty file\n" );
        return false;
    }

    std::ofstream out( file.c_str(), std::ios_base::out | std::ios_base::binary );
    if ( !out.is_open() )
    {
        printf( "file: can't open file to write\n" );
        return false;
    }

    out.write( &data[0], data.size() );
    out.close();

    return true;
}

} // namespace file

