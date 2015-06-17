#include "proto/transfrom/transfrom_chat.h"

#include "proto/chat/PQChatContent.h"
#include "proto/chat/PRChatContent.h"
#include "proto/chat/PQChatSound.h"
#include "proto/chat/PRChatSound.h"
#include "proto/chat/PQChatBan.h"
#include "proto/chat/PQChatGetTotem.h"
#include "proto/chat/PRChatGetTotem.h"
#include "proto/chat/PQChatGetSoldier.h"
#include "proto/chat/PRChatGetSoldier.h"
#include "proto/chat/PQChatGetEquip.h"
#include "proto/chat/PRChatGetEquip.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_chat::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1012322907 ] = std::make_pair( "PQChatContent", msg_transfrom< PQChatContent > );
    handles[ 2089793380 ] = std::make_pair( "PRChatContent", msg_transfrom< PRChatContent > );
    handles[ 810765027 ] = std::make_pair( "PQChatSound", msg_transfrom< PQChatSound > );
    handles[ 1516629421 ] = std::make_pair( "PRChatSound", msg_transfrom< PRChatSound > );
    handles[ 511928501 ] = std::make_pair( "PQChatBan", msg_transfrom< PQChatBan > );
    handles[ 490478920 ] = std::make_pair( "PQChatGetTotem", msg_transfrom< PQChatGetTotem > );
    handles[ 1814824376 ] = std::make_pair( "PRChatGetTotem", msg_transfrom< PRChatGetTotem > );
    handles[ 557377059 ] = std::make_pair( "PQChatGetSoldier", msg_transfrom< PQChatGetSoldier > );
    handles[ 1530883110 ] = std::make_pair( "PRChatGetSoldier", msg_transfrom< PRChatGetSoldier > );
    handles[ 839851394 ] = std::make_pair( "PQChatGetEquip", msg_transfrom< PQChatGetEquip > );
    handles[ 1265884710 ] = std::make_pair( "PRChatGetEquip", msg_transfrom< PRChatGetEquip > );

    return handles;
}

