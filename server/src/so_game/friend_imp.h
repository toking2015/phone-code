#ifndef _IMMORTAL_SO_GAME_FRIEND_IMP_H_
#define _IMMORTAL_SO_GAME_FRIEND_IMP_H_

#include "common.h"
#include "proto/user.h"

namespace frd
{
    void        ReplyFriendList( SUser* puser );
    void        ReplyFriendLimitList( SUser* puser );
    void        ReplyFriendUpdate( SUser* puser, uint8 set_type, SUserFriend& data );
    void        ReplyFriendLimitUpdate( SUser* puser, uint8 set_type, SFriendLimit& data );

    void        MakeFriend( SUser* puser, uint32 friend_id );
    void        MakeFriendByName( SUser* puser, std::string& target_name );
    void        AddFriend( SUser* puser, uint32 friend_id );
    void        AddStranger( SUser* puser, uint32 target_id );
    void        AddBlack( SUser* puser, uint32 target_id );
    void        UpdateFriend( SUser* puser, uint32 target_id,  uint8 set_type, uint8 group );

    void        Give( SUser* puser, SUser* target, uint8 give_type, uint32 active_score, std::vector< S3UInt32 > &item_list );

    void        Recommend( SUser* puser );

    void        SetData( SUser* puser, SUserFriend& data, uint8 group );
    void        SetDataByFriendData( SFriendData* pdata, SUserFriend& data, uint8 group );

    void        Request( SUser* puser, SUser* target );
    void        SendMsg( SUser* puser, SUser* target, std::string& msg );
}// namespace frd

#endif

