#ifndef _market_H_
#define _market_H_

#include "proto/common.h"

const uint32 kPathMarketReturn = 254524643;
const uint32 kPathMarketCargoUp = 2044516102;
const uint32 kPathMarketCargoDown = 357133648;
const uint32 kPathMarketBuy = 366073746;
const uint32 kPathMarketSell = 930146548;
const uint32 kPathMarketRef = 1892309926;
const uint32 kPathMarketChange = 805155233;
const uint32 kPathMarketAutoBuy = 884419040;
const uint32 kMarketCargoTypePaper = 1;
const uint32 kMarketCargoTypeMaterial = 2;
const uint32 kErrMarketNotService = 1836364015;
const uint32 kErrMarketCargoNoExist = 825506719;
const uint32 kErrMarketCargoNoExchange = 391560087;
const uint32 kErrMarketPercentRound = 1296708022;
const uint32 kErrMarketCargoCate = 1825800181;
const uint32 kErrMarketCargoNotEnough = 2089953920;
const uint32 kErrMarketCargoPurview = 1323018039;
const uint32 kErrMarketCargoChange = 1360020592;
const uint32 kErrMarketParam = 2034222067;
const uint32 kErrMarketNotPaperSkill = 1306858982;
const uint32 kErrMarketRefNotToTime = 545248623;

#include "proto/market/SMarketSellCargo.h"
#include "proto/market/SMarketMatch.h"
#include "proto/market/SMarketLog.h"
#include "proto/market/SMarketIndices.h"
#include "proto/market/CMarket.h"
#include "proto/market/PQMarketBuyList.h"
#include "proto/market/PQMarketCustomBuyList.h"
#include "proto/market/PRMarketCustomBuyList.h"
#include "proto/market/PRMarketBuyList.h"
#include "proto/market/PRMarketBuyData.h"
#include "proto/market/PQMarketSellList.h"
#include "proto/market/PRMarketSellList.h"
#include "proto/market/PRMarketSellData.h"
#include "proto/market/PQMarketCargoUp.h"
#include "proto/market/PQMarketCargoDown.h"
#include "proto/market/PRMarketCargoDown.h"
#include "proto/market/PQMarketCargoChange.h"
#include "proto/market/PQMarketBuy.h"
#include "proto/market/PRMarketBuy.h"
#include "proto/market/PQMarketBuyAll.h"
#include "proto/market/PRMarketBuyAll.h"
#include "proto/market/PQMarketBatchMatch.h"
#include "proto/market/PRMarketBatchMatch.h"
#include "proto/market/PQMarketBatchBuy.h"
#include "proto/market/PRMarketBatchBuy.h"
#include "proto/market/PQMarketSell.h"
#include "proto/market/PRMarketSell.h"
#include "proto/market/PQMarketSocialReset.h"
#include "proto/market/PQMarketDownTimeout.h"
#include "proto/market/PQMarketSellTimeout.h"
#include "proto/market/PQMarketList.h"
#include "proto/market/PRMarketList.h"
#include "proto/market/PRMarketLogData.h"

#endif
