#ifndef _broadcast_H_
#define _broadcast_H_

#include "proto/common.h"

const uint32 kCastUni = 0;
const uint32 kCastServer = 1;
const uint32 kCastCopy = 2;
const uint32 kCastGuild = 3;

#include "proto/broadcast/SUserChannel.h"
#include "proto/broadcast/PQBroadCastList.h"
#include "proto/broadcast/PRBroadCastList.h"
#include "proto/broadcast/PQBroadCastSet.h"

#endif
