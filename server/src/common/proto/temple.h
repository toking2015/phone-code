#ifndef _temple_H_
#define _temple_H_

#include "proto/common.h"

const uint32 kTempleHoleMaxCount = 8;
const uint32 kTempleScoreSoldierCollect = 1;
const uint32 kTempleScoreSoldierLevelUp = 2;
const uint32 kTempleScoreSoldierQuality = 3;
const uint32 kTempleScoreSoldierStar = 4;
const uint32 kTempleScoreTotemCollect = 5;
const uint32 kTempleScoreTotemLevelUp = 6;
const uint32 kTempleScoreTotemSkillLevelUp = 7;
const uint32 kTempleScoreGroupCollect = 8;
const uint32 kTempleScoreGroupLevelUp = 9;
const uint32 kPathTemple = 626346520;
const uint32 kPathTempleScoreReward = 486298842;
const uint32 kPathTempleOpenHole = 563037377;
const uint32 kPathTempleGroupLevelUp = 83421914;
const uint32 kPathTempleEmbedGlyph = 1802264557;
const uint32 kPathTempleTrainGlyph = 31278397;
const uint32 kPathTempleGroupAdd = 1560376085;

#include "proto/temple/STempleGlyph.h"
#include "proto/temple/STempleGroup.h"
#include "proto/temple/STempleInfo.h"
#include "proto/temple/PQTempleInfo.h"
#include "proto/temple/PRTempleInfo.h"
#include "proto/temple/PQTempleGroupLevelUp.h"
#include "proto/temple/PRTempleGroupLevelUp.h"
#include "proto/temple/PQTempleOpenHole.h"
#include "proto/temple/PRTempleOpenHole.h"
#include "proto/temple/PQTempleEmbedGlyph.h"
#include "proto/temple/PRTempleEmbedGlyph.h"
#include "proto/temple/PQTempleGlyphTrain.h"
#include "proto/temple/PRTempleGlyphTrain.h"
#include "proto/temple/PQTempleTakeScoreReward.h"
#include "proto/temple/PRTempleTakeScoreReward.h"

#endif
