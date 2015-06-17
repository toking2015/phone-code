#ifndef _GAMESVR_PROC_H_
#define _GAMESVR_PROC_H_

#include "proto/common.h"
#include "proto/user.h"
#include "misc.h"

void HandleErrCode(SUser* user, uint32 err_no, uint32 err_desc);
void HandleErrCode(SMsgHead& msg, uint32 err_no, uint32 err_desc);

#endif


