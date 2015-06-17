#include "pro.h"
#include "proto/gut.h"
#include "user_dc.h"
#include "gut_imp.h"
#include "user_imp.h"
#include "coin_imp.h"
#include "gut_event.h"

MSG_FUNC( PQGutInfo )
{
    QU_ON( user, msg.role_id );

    gut::reply_gut_info( user, user->data.gut );
}

MSG_FUNC( PQGutCommitEvent )
{
    QU_ON( user, msg.role_id );

    uint32 gut_id = user->data.gut.gut_id;
    uint32 index = user->data.gut.index;

    std::vector< S3UInt32 > give_coins;
    std::vector< S3UInt32 > take_coins;

    int32 result = gut::commit_event_normal( user->data.gut, user->data.gut.index, give_coins, take_coins );
    if ( result != 0 )
    {
        HandleErrCode( user, result, 0 );
        return;
    }

    //扣取货币
    if ( coin::valid( take_coins ) )
        coin::take( user, take_coins, kPathGutCommit );

    //发送奖励
    if ( coin::valid( give_coins ) )
        coin::give( user, give_coins, kPathGutCommit );

    //修改剧情索引, 超出事件重置剧情
    if ( ++user->data.gut.index >= (int32)user->data.gut.event.size() )
        user->data.gut = SGutInfo();

    event::dispatch( SEventGutStepCommit( user, kPathGutCommit, gut_id, index ) );

    //剧情完成事件
    if ( user->data.gut.gut_id == 0 )
    {
        gut::reply_gut_info( user, user->data.gut );

        event::dispatch( SEventGutFinished( user, kPathGutFinish, gut_id ) );
    }
}

