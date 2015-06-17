#ifndef _guild_H_
#define _guild_H_

#include "proto/common.h"

const uint32 kPathGuildInit = 440539142;
const uint32 kPathGuildLoad = 741151118;
const uint32 kPathGuildCreate = 195444527;
const uint32 kPathGuildJoin = 1603195559;
const uint32 kPathGuildExit = 1927710242;
const uint32 kPathGuildJobChange = 810820358;
const uint32 kPathGuildContribute = 94677408;
const uint32 kPathGuildLevelup = 1021453233;
const uint32 kGuild = 241034201;
const uint32 kGuildJobCommon = 1;
const uint32 KGuildJobVip = 2;
const uint32 kGuildJobMaster = 3;
const uint32 kGuildLogMax = 20;
const uint32 kGuildLogJoin = 1;
const uint32 kGuildLogQuit = 2;
const uint32 kGuildLogKick = 3;
const uint32 kGuildLogContribute = 4;
const uint32 kGuildLogLevelup = 5;
const uint32 kGuildLogMasterChange = 6;
const uint32 kErrGuild = 140824409;
const uint32 kErrGuildExist = 128580917;
const uint32 kErrGuildNameEmpty = 583620925;
const uint32 kErrGuildNameSpecial = 836211315;
const uint32 kErrGuildNameExist = 772632695;
const uint32 kErrGuildNoExist = 828404836;
const uint32 kErrGuildExitMaster = 1588120539;
const uint32 kErrGuildJobChangeSelf = 1450063457;
const uint32 kErrGuildJobChangePurview = 1835575541;
const uint32 kErrGuildMemberNoExist = 1736414275;
const uint32 kErrGuildApplyMax = 1315486980;
const uint32 kErrGuildAuthority = 1641952783;
const uint32 kErrGuildApplyFull = 1722585395;
const uint32 kErrGuildData = 1196514008;
const uint32 kErrGuildApplyNotFound = 1909325558;
const uint32 kErrGuildMemberMax = 1328370256;
const uint32 kErrGuildContributeTimeLimit = 1215606341;
const uint32 kErrGuildLevelupXpLack = 1782616349;

#include "proto/guild/SGuildSimple.h"
#include "proto/guild/SGuildLog.h"
#include "proto/guild/SGuildInfo.h"
#include "proto/guild/SGuildProtect.h"
#include "proto/guild/SGuildPanel.h"
#include "proto/guild/SGuildMember.h"
#include "proto/guild/SGuildData.h"
#include "proto/guild/SGuildExt.h"
#include "proto/guild/SGuild.h"
#include "proto/guild/CGuildMap.h"
#include "proto/guild/PQGuildSimple.h"
#include "proto/guild/PRGuildSimple.h"
#include "proto/guild/PQGuildPanel.h"
#include "proto/guild/PRGuildPanel.h"
#include "proto/guild/PQGuildMemberList.h"
#include "proto/guild/PRGuildMemberList.h"
#include "proto/guild/PQGuildList.h"
#include "proto/guild/PRGuildList.h"
#include "proto/guild/PQGuildSimpleList.h"
#include "proto/guild/PRGuildSimpleList.h"
#include "proto/guild/PQGuildCreate.h"
#include "proto/guild/PRGuildCreate.h"
#include "proto/guild/PQGuildInvite.h"
#include "proto/guild/PQGuildApply.h"
#include "proto/guild/PRGuildApplySet.h"
#include "proto/guild/PRGuildApply.h"
#include "proto/guild/PQGuildApprove.h"
#include "proto/guild/PQGuildQuit.h"
#include "proto/guild/PQGuildKick.h"
#include "proto/guild/PQGuildSetJob.h"
#include "proto/guild/PRGuildMemberSet.h"
#include "proto/guild/PQGuildContribute.h"
#include "proto/guild/PQGuildLevelup.h"
#include "proto/guild/PRGuildLevel.h"
#include "proto/guild/PQGuildPost.h"
#include "proto/guild/PRGuildPost.h"

#endif
