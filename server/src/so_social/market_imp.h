#ifndef _SOCIAL_MARKET_IMP_H_
#define _SOCIAL_MARKET_IMP_H_

#include "proto/common.h"
#include "proto/market.h"
#include "resource/r_marketext.h"

namespace market
{

std::vector< uint32 >& switch_cargo_map( uint32 sid, CMarketData::SData* market );

void cargo_up( uint32 sid, uint32 rid, S3UInt32 coin, uint8 precent );
void cargo_down( uint32 rid, uint32 cargo_id );
void cargo_change( uint32 rid, uint32 cargo_id, uint8 percent );
void cargo_buy( uint32 rid, uint32 cargo_id, uint32 count, uint32 value, uint8 percent );
bool cargo_check( uint32 sid, uint32 item_id, uint32 value );       //判断数量是否足够
void batch_match( uint32 sid, uint32 rid, std::vector< S3UInt32 >& coins );
void batch_buy( uint32 sid, uint32 rid, std::vector< SMarketMatch >& cargos, uint32 value, uint32 path );
void cargo_buy_all( uint32 rid, std::vector< S3UInt32 >& coins, uint32 value, uint32 percent );
void cargo_reset( uint32 sid );
void get_buy_list( uint32 sid, uint32 rid, uint32 level );
void get_custom_list( uint32 sid, uint32 rid, uint8 equip, uint16 level );
void get_sell_list( uint32 sid, uint32 rid );

void modify_db_data( uint32 set_type, SMarketSellCargo& cargo );
void down_time_out( uint32 sid );
void sell_time_out( uint32 sid );
void sell_money( uint32 rid, uint32 cargo_id );

} // namespace social

#endif

