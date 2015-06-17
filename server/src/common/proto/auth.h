#ifndef _auth_H_
#define _auth_H_

#include "proto/common.h"

const uint32 kAuthRunJsonFlagError = 0;
const uint32 kAuthRunJsonFlagSucceed = 1;
const uint32 kAuthRunJsonFlagDefer = 2;
const uint32 kAuthRunJsonFlagLoop = 3;

#include "proto/auth/SAuthRunTime.h"
#include "proto/auth/SAuthRunData.h"
#include "proto/auth/CAuth.h"
#include "proto/auth/PQAuthRunJson.h"
#include "proto/auth/PQAuthRunTimeSet.h"
#include "proto/auth/PRAuthRunTimeSet.h"
#include "proto/auth/PQAuthRunTimeList.h"
#include "proto/auth/PRAuthRunTimeList.h"

#endif
