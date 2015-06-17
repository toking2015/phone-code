#include "back_imp.h"
#include "output.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "util.h"
#include "misc.h"
#include "server.h"
#include "settings.h"

SO_LOAD( back_imp_load )
{
    back::open_limit_file();
}

SO_UNLOAD( back_imp_unload )
{
    output::close("");
}

namespace back
{

void open_limit_file(void)
{
    uint32 time_now = server::local_time();

    const char* name_list[] =
    {
        "coins.txt"
    };

    for ( int32 i = 0, count = sizeof( name_list ) / sizeof( const char* );
        i < count;
        ++i )
    {
        output::open( name_list[i], time_now );
    }
}

void close_limit_file(void)
{
    output::close_limit_time( zero_time( time(NULL) ) );
}

} // namespace back

