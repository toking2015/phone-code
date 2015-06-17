#ifndef _IMMORTAL_SO_GAME_PAY_IMP_H_
#define _IMMORTAL_SO_GAME_PAY_IMP_H_

#include "common.h"
#include "proto/user.h"

namespace pay
{

void AddPay( SUser* user, std::vector<SUserPay> &list );
void Process( SUser* user );
void AddMonthTime( SUser* user, uint32 time, uint32 path );
void ReplyData( SUser* user );
void TimeLimit( SUser* user );
void MonthReward( SUser* user );
void GetFristPayReward( SUser* user );

} // namespace pay

#endif

