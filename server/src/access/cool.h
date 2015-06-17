#ifndef _IMMORTAL_ACCESS_COOL_H_
#define _IMMORTAL_ACCESS_COOL_H_

#include "common.h"

namespace cool
{

void append( int32 sock );
bool is_cool( int32 sock );
void release_timeout( int32 seconds );

} // namespace cool

#endif

