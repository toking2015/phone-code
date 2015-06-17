#ifndef _pay_H_
#define _pay_H_

#include "proto/common.h"

const uint32 kPayFlagTake = 1;
const uint32 kPayTypeNormal = 1;
const uint32 kPayTypeSpecial = 2;
const uint32 kPathPay = 1647769913;
const uint32 kPathFirstPay = 1351766338;
const uint32 kPathMonthReward = 1332934034;
const uint32 kPathPayPresent = 1491980783;
const uint32 kErrPayMonthTimeLack = 2072000969;
const uint32 kErrPayMonthRewardHaveGet = 833990684;
const uint32 kErrPayFristPayRewardGet = 953400842;

#include "proto/pay/SUserPayInfo.h"
#include "proto/pay/SUserPay.h"
#include "proto/pay/PQPayList.h"
#include "proto/pay/PRPayList.h"
#include "proto/pay/PQPayInfo.h"
#include "proto/pay/PRPayInfo.h"
#include "proto/pay/PQPayMonthReward.h"
#include "proto/pay/PRPayMonthReward.h"
#include "proto/pay/PQPayFristPayReward.h"
#include "proto/pay/PQReplyFristPayReward.h"
#include "proto/pay/PRReplyFristPayReward.h"
#include "proto/pay/PRPayNotice.h"
#include "proto/pay/PQPayNotice.h"

#endif
