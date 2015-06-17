#ifndef _user_H_
#define _user_H_

#include "proto/common.h"

const uint32 kPathUserLoad = 1764226070;
const uint32 kPathUserInit = 26069095;
const uint32 kPathUserLogin = 367449528;
const uint32 kPathUserEveryDay = 1821417889;
const uint32 kPathUserMeet = 777059757;
const uint32 kErrUser = 242729488;
const uint32 kErrUserNoExist = 1796763675;

#include "proto/user/SUserSimple.h"
#include "proto/user/SUserInfo.h"
#include "proto/user/SUserProtect.h"
#include "proto/user/SUserPanel.h"
#include "proto/user/SUserSingleArenaPanel.h"
#include "proto/user/SUserTombPanel.h"
#include "proto/user/SUserData.h"
#include "proto/user/SUserOther.h"
#include "proto/user/SUserExt.h"
#include "proto/user/SUser.h"
#include "proto/user/CUserMap.h"
#include "proto/user/PQUserSimple.h"
#include "proto/user/PRUserSimple.h"
#include "proto/user/PQUserData.h"
#include "proto/user/PRUserData.h"
#include "proto/user/PRUserOther.h"
#include "proto/user/PQUserPanel.h"
#include "proto/user/PRUserPanel.h"
#include "proto/user/PQUserSingleArenaPanel.h"
#include "proto/user/PRUserSingleArenaPanel.h"
#include "proto/user/PQUserTombPanel.h"
#include "proto/user/PRUserTombPanel.h"
#include "proto/user/PQUserActionSave.h"
#include "proto/user/PRUserTimeLimit.h"

#endif
