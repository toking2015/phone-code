#ifndef _SOCIAL_SOCIAL_IMP_H_
#define _SOCIAL_SOCIAL_IMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/social.h"

namespace social
{

void bind( int32 sock, uint32 sid );
void write( uint32 sid, SMsgHead& msg );
void role( SSocialRole& role );

} // namespace social

#endif
