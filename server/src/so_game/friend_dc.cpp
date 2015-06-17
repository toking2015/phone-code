#include "friend_dc.h"

SFriendData* CFriendDC::FindFriendData( uint32 id )
{
    std::map< uint32, SFriendData >::iterator iter = db().user_id_friend.find( id );
    if ( iter == db().user_id_friend.end() )
        return NULL;

    SFriendData* data = &(iter->second);

    return data;

}

void CFriendDC::SetFriendData( uint32 id, SFriendData& data )
{
    db().user_id_friend[ id ] = data;
}

uint32 CFriendDC::Recommend()
{
    uint32  size = db().user_id_friend.size();
    if( size == 0 )
        return 0;

    uint32 index = TRand( (uint32)0, size - 1 );

    for( std::map< uint32, SFriendData >::iterator iter = db().user_id_friend.begin();
        iter != db().user_id_friend.end();
        ++iter )
    {
        if( index == 0 )
        {
            return iter->first;
        }
        --index;
    }
    return 0;
}

