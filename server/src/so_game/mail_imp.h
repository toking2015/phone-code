#ifndef _IMMORTAL_SO_GAME_MAIL_IMP_H_
#define _IMMORTAL_SO_GAME_MAIL_IMP_H_

#include "common.h"
#include "proto/user.h"
#include "proto/mail.h"

namespace mail
{

//分配 mail_id
uint32 alloc_id( SUser* user );

//发送邮件
void send( uint32 flag, uint32 role_id, std::string sender_name, std::string subject, std::string body );
void send( uint32 flag, uint32 role_id, std::string sender_name, std::string subject, std::string body,
    S3UInt32 coin, uint32 path, uint32 coin_flag = 0 );
void send( uint32 flag, uint32 role_id, std::string sender_name, std::string subject, std::string body,
    std::vector< S3UInt32 > coins, uint32 path, uint32 coin_flag = 0 );

//阅读邮件
uint32 readed( SUser* user, uint32 mail_id );

//领取附件
uint32 take( SUser* user, uint32 mail_id );

//删除邮件
void del( SUser* user, uint32 mail_id );

//返回单邮件数据
void reply_data( SUser* user, uint32 set_type, SUserMail& mail );

}// namespace mail

#endif

