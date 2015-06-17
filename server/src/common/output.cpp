#include "output.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "util.h"
#include "misc.h"
#include "settings.h"

namespace output
{

std::map< std::string, std::map< uint32, int32 > >& files(void)
{
    static std::map< std::string, std::map< uint32, int32 > > map;

    return map;
}

int32 open( std::string name, uint32 time )
{
    struct tm t_tm = {0};
    time_t t_time = time;

    localtime_r( &t_time, &t_tm );
    t_tm.tm_hour = 0;
    t_tm.tm_min = 0;
    t_tm.tm_sec = 0;

    // 0 点时间
    time = mktime( &t_tm );

    std::map< uint32, int32 >& file_map = files()[ name ];

    int32 file = file_map[ time ];
    if ( file <= 0 )
    {
        std::string pathname = strprintf( "%s/%d-%.2d-%.2d",
            settings::json()[ "log_path" ].asString().c_str(),
            t_tm.tm_year + 1900, t_tm.tm_mon + 1, t_tm.tm_mday );

        std::string filename = strprintf( "%s/%s", pathname.c_str(), name.c_str() );

        umask(0);
        mkdir( pathname.c_str(), 0777 );

        file = ::open( filename.c_str(), O_APPEND | O_CREAT | O_WRONLY | O_LARGEFILE | O_NONBLOCK, 0777 );

        if ( file > 0 )
            file_map[ time ] = file;
    }

    return file;
}

void write( std::string& name, std::string& text, uint32 time )
{
    int32 file = open( name, time );
    if ( file <= 0 )
        return;

    if ( text.empty() )
    {
        //如果文件为空, 即同步数据落地
        fsync( file );
    }
    else
    {
        ::write( file, text.c_str(), text.size() );
        ::write( file, "\n", 1 );
    }
}

void close( std::string name )
{
    if ( !name.empty() )
    {
        std::map< std::string, std::map< uint32, int32 > >::iterator iter = files().find( name );

        for ( std::map< uint32, int32 >::iterator i = iter->second.begin();
            i != iter->second.end();
            ++i )
        {
            if ( i->second > 0 )
                ::close( i->second );
        }

        files().erase( iter );
        return;
    }

    for ( std::map< std::string, std::map< uint32, int32 > >::iterator iter = files().begin();
        iter != files().end();
        ++iter )
    {
        for ( std::map< uint32, int32 >::iterator i = iter->second.begin();
            i != iter->second.end();
            ++i )
        {
            if ( i->second > 0 )
                ::close( i->second );
        }
    }
    files().clear();
}

void close_limit_time( uint32 limit_time )
{
    for ( std::map< std::string, std::map< uint32, int32 > >::iterator iter = files().begin();
        iter != files().end();
        ++iter )
    {
        for ( std::map< uint32, int32 >::iterator i = iter->second.begin();
            i != iter->second.end(); )
        {
            if ( i->first < limit_time )
            {
                if ( i->second > 0 )
                    ::close( i->second );

                iter->second.erase(i++);
                continue;
            }

            ++i;
        }
    }
}

} // namespace output
