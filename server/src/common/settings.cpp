#include "settings.h"

namespace settings
{

std::vector< CJson > json_list;
int32 json_index = -1;
std::string last_file_name;

bool read( const char* file )
{
    if ( file == NULL || file[0] == '\0' )
        file = last_file_name.c_str();

    CJson data;
    if ( !data.read( file, CJson::kFile ) )
        return false;

    last_file_name = file;

    json_list.push_back( data );
    json_index = json_list.size() - 1;

    return true;
}

CJson& json(void)
{
    return json_list[ json_index ];
}

} // namespace settings
