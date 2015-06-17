#ifndef _paper_H_
#define _paper_H_

#include "proto/common.h"

const uint32 kMaterialCollectMaxTime = 30;
const uint32 kMaterialRefreshInterval = 300;
const uint32 kPathPaperSkillLevelUp = 458509659;
const uint32 kPathPaperSkillForget = 30404056;
const uint32 kPathPaperCreate = 1326081307;
const uint32 kPathCopyCollect = 2979731;
const uint32 kPathActiveScoreReset = 458473657;
const uint32 kErrPaperWrongSkillType = 2128884591;
const uint32 kErrPaperCreateLevelLimit = 2073047348;
const uint32 kErrPaperCollectTimeLimit = 1973576321;

#include "proto/paper/SUserCopyMaterial.h"
#include "proto/paper/PQPaperLevelUp.h"
#include "proto/paper/PQPaperForget.h"
#include "proto/paper/PQPaperCreate.h"
#include "proto/paper/PRPaperCreate.h"
#include "proto/paper/PQPaperCollect.h"
#include "proto/paper/PRPaperCopyMaterialPoint.h"
#include "proto/paper/PRPaperCollect.h"
#include "proto/paper/PRPaperCopyMaterial.h"

#endif
