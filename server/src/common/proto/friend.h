#ifndef _friend_H_
#define _friend_H_

#include "proto/common.h"

const uint32 kPathFriendSend = 281860286;
const uint32 kFriendGroupFriendMax = 300;
const uint32 kFriendGroupStrangerMax = 20;
const uint32 kFriendGroupBlackMax = 100;
const uint32 kFriendGroupFriend = 1;
const uint32 kFriendGroupStranger = 2;
const uint32 kFriendGroupBlack = 3;
const uint32 kFriendGroupMin = 1;
const uint32 kFriendGroupMax = 3;
const uint32 kFriendGiveOne = 1;
const uint32 kFriendGiveTwo = 2;
const uint32 kErrFriendNoExist = 490289517;
const uint32 kErrFriendExist = 1695025934;
const uint32 kErrFriendUpdateParam = 766246230;
const uint32 kErrFriendGroupNotExist = 124451776;
const uint32 kErrFriendUpdateNoModified = 2074697868;
const uint32 kErrFriendNormalMax = 818456875;
const uint32 kErrFriendBlackMax = 343459166;
const uint32 kErrFriendSelf = 2099224127;
const uint32 kErrFriendOffline = 1655785705;
const uint32 kErrFriendNotOpenForSelf = 127496527;
const uint32 kErrFriendNotOpen = 190831468;
const uint32 kErrFriendNoExistMine = 160051431;
const uint32 kErrFriendActiveScoreNoEnough = 308820968;
const uint32 kErrFriendActiveScoreLimit = 1685755119;
const uint32 kErrFriendItemSendNumLimit = 412669810;
const uint32 kErrFriendItemMaxNumLimit = 1582419102;
const uint32 kErrFriendActiveScoreMaxNumLimit = 1066440386;
const uint32 kErrFriendItemEorror = 243558005;
const uint32 kErrFriendItemNoNum = 1326730937;
const uint32 kErrFriendItemNumNoEnough = 1624525327;
const uint32 kErrFriendFightNoOpenSinglearenaOne = 997390259;
const uint32 kErrFriendFightNoOpenSinglearenaTwo = 260992085;
const uint32 kErrFriendSelfLevelLimit = 723363019;
const uint32 kErrFriendFrinedLevelLimit = 1925873372;

#include "proto/friend/SUserFriend.h"
#include "proto/friend/SFriendLimit.h"
#include "proto/friend/SFriendData.h"
#include "proto/friend/CFriend.h"
#include "proto/friend/PQFriendList.h"
#include "proto/friend/PQFriendLimitList.h"
#include "proto/friend/PQFriendMake.h"
#include "proto/friend/PQFriendMakeByName.h"
#include "proto/friend/PQFriendMakeAll.h"
#include "proto/friend/PQFriendUpdate.h"
#include "proto/friend/PQFriendRequest.h"
#include "proto/friend/PQFriendMsg.h"
#include "proto/friend/PQFriendOK.h"
#include "proto/friend/PQSFriendRecommend.h"
#include "proto/friend/PQFriendFightApply.h"
#include "proto/friend/PQFriendGive.h"
#include "proto/friend/PQFriendChatContent.h"
#include "proto/friend/PQFriendBlack.h"
#include "proto/friend/PQFriendBlackByName.h"
#include "proto/friend/PRFriendList.h"
#include "proto/friend/PRFriendLimitList.h"
#include "proto/friend/PRFriendMake.h"
#include "proto/friend/PRFriendRequest.h"
#include "proto/friend/PRFriendUpdate.h"
#include "proto/friend/PRFriendLimitUpdate.h"
#include "proto/friend/PRFriendMsg.h"
#include "proto/friend/PRFriendRecommend.h"
#include "proto/friend/PRFriendGive.h"
#include "proto/friend/PRFriendChatContent.h"
#include "proto/friend/PRFriendGiveLimit.h"

#endif
