#ifndef _IMMORTALSO_GAME_COIN_IMP_H_
#define _IMMORTALSO_GAME_COIN_IMP_H_

#include "proto/user.h"
#include "proto/coin.h"

namespace coin
{

//判断货币是否为有效货币( 只检查货币类型和货币值 != 0 )
bool valid( S3UInt32& coin );

//存在1个或以上有效货币, 即返回 true, 空列表也会返回 false
bool valid( std::vector< S3UInt32 >& coins );

S3UInt32 create( uint32 cate, uint32 objid, uint32 val );

//获取当前货币量
uint32 count( SUser* user, S3UInt32& coin );

//给予货币, overflow 为允许基本类型数据溢出 space空间 进行give
//flag: kCoinFlagXXX
void give( SUser* user, S3UInt32& coin, uint32 path, uint32 flag = 0 );
void give( SUser* user, std::vector< S3UInt32 > coins, uint32 path, uint32 flag = 0 );

//检查是否有足够空间给予货币, 返回空间不足的货币类型 kCoinXXX
uint32 check_give( SUser* user, S3UInt32& coin );
uint32 check_give( SUser* user, std::vector< S3UInt32 >& coins );

//扣取货币( 有多少扣多少, 不作货币不够的判断 )
//flag: kCoinFlagXXX
void take( SUser* user, S3UInt32& coin, uint32 path, uint32 flag = 0 );
void take( SUser* user, std::vector< S3UInt32 > coins, uint32 path, uint32 flag = 0 );

//检查货币是否足够扣取货币, 返回0为成功, 非0为缺少的货币类型
uint32 check_take( SUser* user, S3UInt32& coin );
uint32 check_take( SUser* user, std::vector< S3UInt32 >& coins );

//获取货币剩余空间
uint32 space( SUser* user, S3UInt32& coin );
uint32 space( SUser* user, uint32 cate );

//返回货币缺失
void reply_lack( SUser* user, uint32 type );

} // namespace coin

#endif

