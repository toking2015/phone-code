#ifndef _GAMESVR_FRIEND_DC_H_
#define _GAMESVR_FRIEND_DC_H_

#include "dc.h"
#include "proto/friend.h"

class CFriendDC : public TDC< CFriend >
{
public:
    CFriendDC() : TDC< CFriend >( "friend" )
    {
    }

public:
    SFriendData* FindFriendData( uint32 id );
    void SetFriendData( uint32 id, SFriendData& data );
    uint32 Recommend();
};
#define theFriendDC TSignleton< CFriendDC >::Ref()

#endif

