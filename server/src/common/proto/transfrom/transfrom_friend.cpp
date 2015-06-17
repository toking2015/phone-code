#include "proto/transfrom/transfrom_friend.h"

#include "proto/friend/SUserFriend.h"
#include "proto/friend/SFriendLimit.h"
#include "proto/friend/SFriendData.h"
#include "proto/friend/CFriend.h"
#include "proto/friend/PQFriendList.h"
#include "proto/friend/PQFriendLimitList.h"
#include "proto/friend/PQFriendMake.h"
#include "proto/friend/PQFriendMakeByName.h"
#include "proto/friend/PQFriendMakeAll.h"
#include "proto/friend/PQFriendUpdate.h"
#include "proto/friend/PQFriendRequest.h"
#include "proto/friend/PQFriendMsg.h"
#include "proto/friend/PQFriendOK.h"
#include "proto/friend/PQSFriendRecommend.h"
#include "proto/friend/PQFriendFightApply.h"
#include "proto/friend/PQFriendGive.h"
#include "proto/friend/PQFriendChatContent.h"
#include "proto/friend/PQFriendBlack.h"
#include "proto/friend/PQFriendBlackByName.h"
#include "proto/friend/PRFriendList.h"
#include "proto/friend/PRFriendLimitList.h"
#include "proto/friend/PRFriendMake.h"
#include "proto/friend/PRFriendRequest.h"
#include "proto/friend/PRFriendUpdate.h"
#include "proto/friend/PRFriendLimitUpdate.h"
#include "proto/friend/PRFriendMsg.h"
#include "proto/friend/PRFriendRecommend.h"
#include "proto/friend/PRFriendGive.h"
#include "proto/friend/PRFriendChatContent.h"
#include "proto/friend/PRFriendGiveLimit.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_friend::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 511240001 ] = std::make_pair( "PQFriendList", msg_transfrom< PQFriendList > );
    handles[ 961802699 ] = std::make_pair( "PQFriendLimitList", msg_transfrom< PQFriendLimitList > );
    handles[ 227513378 ] = std::make_pair( "PQFriendMake", msg_transfrom< PQFriendMake > );
    handles[ 606583061 ] = std::make_pair( "PQFriendMakeByName", msg_transfrom< PQFriendMakeByName > );
    handles[ 698155518 ] = std::make_pair( "PQFriendMakeAll", msg_transfrom< PQFriendMakeAll > );
    handles[ 455135086 ] = std::make_pair( "PQFriendUpdate", msg_transfrom< PQFriendUpdate > );
    handles[ 638251957 ] = std::make_pair( "PQFriendRequest", msg_transfrom< PQFriendRequest > );
    handles[ 654453972 ] = std::make_pair( "PQFriendMsg", msg_transfrom< PQFriendMsg > );
    handles[ 518108368 ] = std::make_pair( "PQFriendOK", msg_transfrom< PQFriendOK > );
    handles[ 896220725 ] = std::make_pair( "PQSFriendRecommend", msg_transfrom< PQSFriendRecommend > );
    handles[ 1017508629 ] = std::make_pair( "PQFriendFightApply", msg_transfrom< PQFriendFightApply > );
    handles[ 99204853 ] = std::make_pair( "PQFriendGive", msg_transfrom< PQFriendGive > );
    handles[ 952948261 ] = std::make_pair( "PQFriendChatContent", msg_transfrom< PQFriendChatContent > );
    handles[ 951417580 ] = std::make_pair( "PQFriendBlack", msg_transfrom< PQFriendBlack > );
    handles[ 510925146 ] = std::make_pair( "PQFriendBlackByName", msg_transfrom< PQFriendBlackByName > );
    handles[ 1257022854 ] = std::make_pair( "PRFriendList", msg_transfrom< PRFriendList > );
    handles[ 2023511142 ] = std::make_pair( "PRFriendLimitList", msg_transfrom< PRFriendLimitList > );
    handles[ 1500965640 ] = std::make_pair( "PRFriendMake", msg_transfrom< PRFriendMake > );
    handles[ 1217836923 ] = std::make_pair( "PRFriendRequest", msg_transfrom< PRFriendRequest > );
    handles[ 1160251020 ] = std::make_pair( "PRFriendUpdate", msg_transfrom< PRFriendUpdate > );
    handles[ 1518846405 ] = std::make_pair( "PRFriendLimitUpdate", msg_transfrom< PRFriendLimitUpdate > );
    handles[ 1577180918 ] = std::make_pair( "PRFriendMsg", msg_transfrom< PRFriendMsg > );
    handles[ 1933510749 ] = std::make_pair( "PRFriendRecommend", msg_transfrom< PRFriendRecommend > );
    handles[ 1458158398 ] = std::make_pair( "PRFriendGive", msg_transfrom< PRFriendGive > );
    handles[ 1507929832 ] = std::make_pair( "PRFriendChatContent", msg_transfrom< PRFriendChatContent > );
    handles[ 1699757452 ] = std::make_pair( "PRFriendGiveLimit", msg_transfrom< PRFriendGiveLimit > );

    return handles;
}

