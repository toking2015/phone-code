#ifndef _totem_H_
#define _totem_H_

#include "proto/common.h"

const uint32 kTotemTypeDaDi = 1;
const uint32 kTotemTypeHuoYan = 2;
const uint32 kTotemTypeShuiLiu = 3;
const uint32 kTotemTypeKongQi = 4;
const uint32 kTotemSkillTypeSpeed = 1;
const uint32 kTotemSkillTypeFormationAdd = 2;
const uint32 kTotemSkillTypeWake = 3;
const uint32 kTotemFormationAddPosition = 1;
const uint32 kTotemFormationAddType = 2;
const uint32 kTotemFormationAddTypeFrontRow = 1;
const uint32 kTotemFormationAddTypeBackRow = 2;
const uint32 kTotemFormationAddTypeColumn = 3;
const uint32 kTotemFormationAddTypeTotem = 4;
const uint32 kTotemEmbedGlyphMaxCount = 4;
const uint32 kTotemPacketNormal = 0;
const uint32 kTotemPacketYesterday = 1;
const uint32 kPathTotemUserInit = 556093447;
const uint32 kPathTotemTrain = 532779750;
const uint32 kPathTotemAccelerate = 1679177212;
const uint32 kPathTotemGlyphMerge = 818430494;
const uint32 kPathTotemGlyphEmbed = 345869345;
const uint32 kPathTotemActivate = 696632415;
const uint32 kErrUnkownTotem = 803178191;
const uint32 kErrTotemAlreadyExist = 2135017583;
const uint32 kErrTotemNoExist = 1988007228;
const uint32 kErrTotemDuringEnergy = 366864623;

#include "proto/totem/STotem.h"
#include "proto/totem/STotemGlyph.h"
#include "proto/totem/STotemInfo.h"
#include "proto/totem/PQTotemInfo.h"
#include "proto/totem/PRTotemInfo.h"
#include "proto/totem/PQTotemActivate.h"
#include "proto/totem/PRTotemActivate.h"
#include "proto/totem/PQTotemBless.h"
#include "proto/totem/PRTotemBless.h"
#include "proto/totem/PQTotemAddEnergy.h"
#include "proto/totem/PRTotemAddEnergy.h"
#include "proto/totem/PQTotemAccelerate.h"
#include "proto/totem/PRTotemAccelerate.h"
#include "proto/totem/PQTotemGlyphMerge.h"
#include "proto/totem/PRTotemGlyphMerge.h"
#include "proto/totem/PQTotemGlyphEmbed.h"
#include "proto/totem/PRTotemGlyphEmbed.h"

#endif
