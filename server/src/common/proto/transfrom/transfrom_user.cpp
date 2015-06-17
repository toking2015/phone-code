#include "proto/transfrom/transfrom_user.h"

#include "proto/user/SUserSimple.h"
#include "proto/user/SUserInfo.h"
#include "proto/user/SUserProtect.h"
#include "proto/user/SUserPanel.h"
#include "proto/user/SUserSingleArenaPanel.h"
#include "proto/user/SUserTombPanel.h"
#include "proto/user/SUserData.h"
#include "proto/user/SUserOther.h"
#include "proto/user/SUserExt.h"
#include "proto/user/SUser.h"
#include "proto/user/CUserMap.h"
#include "proto/user/PQUserSimple.h"
#include "proto/user/PRUserSimple.h"
#include "proto/user/PQUserData.h"
#include "proto/user/PRUserData.h"
#include "proto/user/PRUserOther.h"
#include "proto/user/PQUserPanel.h"
#include "proto/user/PRUserPanel.h"
#include "proto/user/PQUserSingleArenaPanel.h"
#include "proto/user/PRUserSingleArenaPanel.h"
#include "proto/user/PQUserTombPanel.h"
#include "proto/user/PRUserTombPanel.h"
#include "proto/user/PQUserActionSave.h"
#include "proto/user/PRUserTimeLimit.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_user::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 455141318 ] = std::make_pair( "PQUserSimple", msg_transfrom< PQUserSimple > );
    handles[ 1175044508 ] = std::make_pair( "PRUserSimple", msg_transfrom< PRUserSimple > );
    handles[ 955700884 ] = std::make_pair( "PQUserData", msg_transfrom< PQUserData > );
    handles[ 2136523129 ] = std::make_pair( "PRUserData", msg_transfrom< PRUserData > );
    handles[ 2131699547 ] = std::make_pair( "PRUserOther", msg_transfrom< PRUserOther > );
    handles[ 945575969 ] = std::make_pair( "PQUserPanel", msg_transfrom< PQUserPanel > );
    handles[ 1395064671 ] = std::make_pair( "PRUserPanel", msg_transfrom< PRUserPanel > );
    handles[ 78072471 ] = std::make_pair( "PQUserSingleArenaPanel", msg_transfrom< PQUserSingleArenaPanel > );
    handles[ 1447792173 ] = std::make_pair( "PRUserSingleArenaPanel", msg_transfrom< PRUserSingleArenaPanel > );
    handles[ 923525520 ] = std::make_pair( "PQUserTombPanel", msg_transfrom< PQUserTombPanel > );
    handles[ 2067373703 ] = std::make_pair( "PRUserTombPanel", msg_transfrom< PRUserTombPanel > );
    handles[ 658374206 ] = std::make_pair( "PQUserActionSave", msg_transfrom< PQUserActionSave > );
    handles[ 1931081387 ] = std::make_pair( "PRUserTimeLimit", msg_transfrom< PRUserTimeLimit > );

    return handles;
}

