#include "star_imp.h"
#include "proto/star.h"
#include "local.h"

namespace star
{

void reply_data( SUser* user )
{
    PRStarData rep;
    bccopy( rep, user->ext );

    rep.data = user->data.star;

    local::write( local::access, rep );
}

} // namespace star

