#ifndef _opentarget_H_
#define _opentarget_H_

#include "proto/common.h"

const uint32 kPathOpenTargetBuy = 448618963;
const uint32 kPathOpenTargetTake = 1789308928;
const uint32 kOpenTargetActionTypeBuy = 4;
const uint32 kOpenTargetIfTypeLogin = 1;
const uint32 kOpenTargetIfTypeAddPay = 2;
const uint32 kOpenTargetIfTypeMainCopy = 3;
const uint32 kOpenTargetIfTypePefectCopy = 4;
const uint32 kOpenTargetIfTypeTeamLevel = 5;
const uint32 kOpenTargetIfTypeEquip = 6;
const uint32 kOpenTargetIfTypeSoldier = 7;
const uint32 kOpenTargetIfTypeSingleare = 8;
const uint32 kOpenTargetIfTypeTomb = 9;
const uint32 kOpenTargetIfTypeTotem = 10;
const uint32 kOpenTargetIfTypeSoldierTeam = 11;
const uint32 kOpenTargetIfTypeGlyph = 12;
const uint32 kOpenTargetIfTypeAll = 100;

#include "proto/opentarget/PQOpenTargetTake.h"
#include "proto/opentarget/PROpenTargetTake.h"
#include "proto/opentarget/PQOpenTargetBuy.h"
#include "proto/opentarget/PROpenTargetBuy.h"

#endif
