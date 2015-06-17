#ifndef _IMMORTAL_SO_GAME_VAR_IMP_H_
#define _IMMORTAL_SO_GAME_VAR_IMP_H_

#include "common.h"
#include "proto/user.h"

namespace var
{

//默认值为 0
uint32 get( SUser* user,  std::string key );

//设置临时变量
//@timelimit 变量有效期
void set( SUser* user, std::string key, uint32 value, uint32 timelimit = 0 );

//删除临时变量
void del( SUser* user, std::string key );

//只针对活动Activity
void setOnActivity( SUser* user, std::string key, uint32 value, uint32 timelimit = 0 );
void delOnActivity( SUser* user, std::string key );

}// namespace var

#endif

