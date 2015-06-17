#ifndef IMMORTAL_GAMESVR_FORMATIONIMP_H_
#define IMMORTAL_GAMESVR_FORMATIONIMP_H_

#include "common.h"
#include "proto/formation.h"
#include "proto/user.h"
/*
 * 阵型功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace formation
{
    //是否是合法阵型type
    bool IsValidType(SUser *user, std::vector<SUserFormation> &formation, uint32 type);
    bool CheckExist(SUser *user, std::vector<SUserFormation> &formation);
    bool CheckIndex(SUser *user, std::vector<SUserFormation> &formation);
    bool CheckAttr(std::vector<SUserFormation> &formation);
    bool CheckCount(SUser *user, std::vector<SUserFormation> &formation);
    bool CheckSameGuid(SUser *user, std::vector<SUserFormation> &formation);
    bool CheckSameIndex(SUser *user, std::vector<SUserFormation> &formation);
    void SetFormationType(uint32 type, std::vector<SUserFormation> &formation);
    uint32 GetYesCount( SUser *puser, uint32 type );
    //初始化
    void Init( SUser *puser, uint32 type );
    void GetFormation( SUser *puser, uint32 type, std::vector<SUserFormation>& formation_list );

    //回复阵型列表
    void ReplyList( SUser *puser, uint32 type );
    //发送阵型变化
    bool Set( SUser *puser, std::vector<SUserFormation>& formation, uint32 set_type );
    //删除图腾
    void DelTotem( SUser *puser, uint32 totem_guid );
}// namespace formation

#endif  //IMMORTAL_GAMESVR_FORMATIONIMP_H_
