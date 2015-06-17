#ifndef IMMORTAL_GAMESVR_REPORTPOSTIMP_H_
#define IMMORTAL_GAMESVR_REPORTPOSTIMP_H_

#include "common.h"
#include "proto/singlearena.h"
#include "proto/user.h"
#include "local.h"

namespace reportpost
{
    //举报
    void    Report( SUser* puser, SUser* target );
    void    UserLoaded( SUser* puser );
    void    TimeLimit( SUser* puser );

    //更新
    void    UpdateInfoToDB( uint8 set_type, uint32 target_id, uint32 report_id, uint32 report_time );

} // namespace reportpost

#endif  //IMMORTAL_GAMESVR_REPORTPOSTIMP_H_
