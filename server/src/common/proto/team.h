#ifndef _team_H_
#define _team_H_

#include "proto/common.h"

const uint32 kPathTeamLevelUp = 308776875;
const uint32 kPathChangeName = 1924174318;
const uint32 kPathChangeAvatar = 84965152;
const uint32 kErrTeamNameHave = 1579822034;
const uint32 kErrTeamNameLong = 1145027880;
const uint32 kErrTeamNameInvalid = 1747010135;
const uint32 kErrTeamAvatarNoExist = 449384382;

#include "proto/team/STeamInfo.h"
#include "proto/team/PQTeamLevelUp.h"
#include "proto/team/PRTeamLevelUp.h"
#include "proto/team/PQTeamChangeName.h"
#include "proto/team/PRTeamChangeName.h"
#include "proto/team/PQTeamChangeAvatar.h"

#endif
