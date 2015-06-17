#include "system_imp.h"
#include "proto/system.h"
#include "local.h"

namespace sys
{

void placard( uint8 order, uint8 flag, std::string text, uint16 broad_cast, uint16 broad_type, uint32 broad_id )
{
    PRSystemPlacard msg;

    msg.broad_cast      = broad_cast;
    msg.broad_type      = broad_type;
    msg.broad_id        = broad_id;

    msg.order           = order;
    msg.flag            = flag;
    msg.text            = text;

    local::write( local::access, msg );
}

} // namespace sys
