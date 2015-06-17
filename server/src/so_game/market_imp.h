#ifndef _GAME_MARKET_IMP_H_
#define _GAME_MARKET_IMP_H_

#include "proto/market.h"
#include "proto/user.h"

namespace market
{

//根据开服时间返回 sid, 开服第 8 天返回 sid = 0, 使用跨服拍卖行数据
uint32 get_social_sid(void);

void reply_log_data( SUser* user, SMarketLog& data );

} // namespace market

#endif

