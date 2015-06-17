#ifndef _system_H_
#define _system_H_

#include "proto/common.h"

const uint32 kPathSystemAuto = 1447752712;
const uint32 kPlacardFlagScene = 1;
const uint32 kPlacardFlagChat = 2;
const uint32 kPlacardFlagMsgBox = 4;
const uint32 kErrSystem = 477806953;
const uint32 kErrSystemBusy = 191323984;
const uint32 kErrSystemSession = 437223085;
const uint32 kErrSystemRemoteLogin = 1458683342;
const uint32 kErrSystemUnusualError = 572359966;
const uint32 kErrSystemResend = 195292953;

#include "proto/system/CSystem.h"
#include "proto/system/PQSystemTest.h"
#include "proto/system/PRSystemTest.h"
#include "proto/system/PQSystemPing.h"
#include "proto/system/PRSystemPing.h"
#include "proto/system/PQSystemOnline.h"
#include "proto/system/PQSystemResend.h"
#include "proto/system/PRSystemResend.h"
#include "proto/system/PRSystemNetConnected.h"
#include "proto/system/PRSystemNetDisconnected.h"
#include "proto/system/PQSystemSessionCheck.h"
#include "proto/system/PRSystemSessionCheck.h"
#include "proto/system/PQSystemAuth.h"
#include "proto/system/PRSystemAuth.h"
#include "proto/system/PQSystemLogin.h"
#include "proto/system/PRSystemLogin.h"
#include "proto/system/PRSystemUserLoad.h"
#include "proto/system/PRSystemGuildLoad.h"
#include "proto/system/PRSystemUserUpdateSession.h"
#include "proto/system/PRSystemErrCode.h"
#include "proto/system/PQSystemOrder.h"
#include "proto/system/PRSystemOrder.h"
#include "proto/system/PQSystemKick.h"
#include "proto/system/PRSystemKick.h"
#include "proto/system/PQSystemPlacard.h"
#include "proto/system/PRSystemPlacard.h"

#endif
