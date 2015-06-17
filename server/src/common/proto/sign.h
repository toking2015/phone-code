#ifndef _sign_H_
#define _sign_H_

#include "proto/common.h"

const uint32 kSignNormal = 1;
const uint32 kSignAdditional = 2;
const uint32 kPathSign = 947156890;
const uint32 kErrSignBeforeSvrOpen = 1767476840;

#include "proto/sign/SSign.h"
#include "proto/sign/SSignInfo.h"
#include "proto/sign/PQSignInfo.h"
#include "proto/sign/PRSignInfo.h"
#include "proto/sign/PQSign.h"
#include "proto/sign/PRSign.h"
#include "proto/sign/PQTakeSignSumReward.h"
#include "proto/sign/PRTakeSignSumReward.h"
#include "proto/sign/PQTakeHaohuaReward.h"
#include "proto/sign/PRTakeHaohuaReward.h"

#endif
