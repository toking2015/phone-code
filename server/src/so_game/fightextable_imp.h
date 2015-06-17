#ifndef IMMORTAL_GAMESVR_FIGHTEXTABLEIMP_H_
#define IMMORTAL_GAMESVR_FIGHTEXTABLEIMP_H_

#include "common.h"
#include "proto/fightextable.h"
#include "proto/user.h"

/*
 * 二级属性
 * 学习/重置
 */

namespace fightextable
{
    bool IsValidAttr( uint32 attr );
    bool GetAbleInfo( SUser *user, uint32 guid, uint32 attr, SFightExtAbleInfo &fightextable );
    bool GetFightExtAble( SUser *user, uint32 guid, uint32 attr, SFightExtAble &fightextable );
    uint32 GetFightExtAbleHP( SUser *user, uint32 guid, uint32 attr );
    void UpdateSoldierAble( SUser *user, S2UInt32 soldier, uint32 path );
    void UpdateAllAble( SUser *user, uint32 path );
    void ReplyList( SUser *puser, uint32 attr );
    void ReplySet( SUser *puser, std::vector<SFightExtAbleInfo>& fightextable, uint32 set_type );
    void Init( SUser *puser );
    void UpdateFightValue( SUser *user );
    uint32 GetFightValue( SUser *user, uint32 type );
}// namespace fightextable

#endif  //IMMORTAL_GAMESVR_FIGHTEXTABLEIMP_H_
