#ifndef _back_H_
#define _back_H_

#include "proto/common.h"

const uint32 kBackObserver = 1;
const uint32 kBackExecutor = 2;
const uint32 kBackGrounder = 4;
const uint32 kBackInnerAcc = 8;
const uint32 kBackInstructor = 16;
const uint32 kBackGameMaster = 32;

#include "proto/back/PQBackLog.h"

#endif
