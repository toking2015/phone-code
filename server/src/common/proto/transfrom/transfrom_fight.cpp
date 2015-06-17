#include "proto/transfrom/transfrom_fight.h"

#include "proto/fight/SFightOrder.h"
#include "proto/fight/SFightSkill.h"
#include "proto/fight/SFightExtAble.h"
#include "proto/fight/SFightOdd.h"
#include "proto/fight/SFightOddSet.h"
#include "proto/fight/SFightOddTriggered.h"
#include "proto/fight/SFightOrderTarget.h"
#include "proto/fight/SFightLog.h"
#include "proto/fight/SFightSkillObject.h"
#include "proto/fight/SFightSoldierSimple.h"
#include "proto/fight/SFightSoldier.h"
#include "proto/fight/SFightPlayerSimple.h"
#include "proto/fight/SFightPlayerInfo.h"
#include "proto/fight/SFightResult.h"
#include "proto/fight/SFightLogList.h"
#include "proto/fight/SFightRecordSimple.h"
#include "proto/fight/SFightRecord.h"
#include "proto/fight/SSoldier.h"
#include "proto/fight/SFightEndInfo.h"
#include "proto/fight/SFight.h"
#include "proto/fight/CFightData.h"
#include "proto/fight/CFightMap.h"
#include "proto/fight/CFightRecordMap.h"
#include "proto/fight/PQCommonFightApply.h"
#include "proto/fight/PRCommonFightInfo.h"
#include "proto/fight/PRCommonFightServerEnd.h"
#include "proto/fight/PQCommonFightClientEnd.h"
#include "proto/fight/PRCommonFightClientEnd.h"
#include "proto/fight/PQPlayerFightApply.h"
#include "proto/fight/PRPlayerFightInfo.h"
#include "proto/fight/PQPlayerFightQuit.h"
#include "proto/fight/PQPlayerFightAck.h"
#include "proto/fight/PRPlayerFightAck.h"
#include "proto/fight/PQPlayerFightSyn.h"
#include "proto/fight/PRFightRoundData.h"
#include "proto/fight/PRFightEnd.h"
#include "proto/fight/PQFightRecordSave.h"
#include "proto/fight/PQFightRecordGet.h"
#include "proto/fight/PRFightRecordGet.h"
#include "proto/fight/PQFightRecordID.h"
#include "proto/fight/PRFightRecordID.h"
#include "proto/fight/PQFightFirstShow.h"
#include "proto/fight/PQFightSingleArenaApply.h"
#include "proto/fight/PQFightErrorLog.h"
#include "proto/fight/PQCommonFightAuto.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_fight::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 477321402 ] = std::make_pair( "PQCommonFightApply", msg_transfrom< PQCommonFightApply > );
    handles[ 1926767447 ] = std::make_pair( "PRCommonFightInfo", msg_transfrom< PRCommonFightInfo > );
    handles[ 1338160097 ] = std::make_pair( "PRCommonFightServerEnd", msg_transfrom< PRCommonFightServerEnd > );
    handles[ 228122789 ] = std::make_pair( "PQCommonFightClientEnd", msg_transfrom< PQCommonFightClientEnd > );
    handles[ 1435883798 ] = std::make_pair( "PRCommonFightClientEnd", msg_transfrom< PRCommonFightClientEnd > );
    handles[ 511019853 ] = std::make_pair( "PQPlayerFightApply", msg_transfrom< PQPlayerFightApply > );
    handles[ 1136960421 ] = std::make_pair( "PRPlayerFightInfo", msg_transfrom< PRPlayerFightInfo > );
    handles[ 761774693 ] = std::make_pair( "PQPlayerFightQuit", msg_transfrom< PQPlayerFightQuit > );
    handles[ 108217511 ] = std::make_pair( "PQPlayerFightAck", msg_transfrom< PQPlayerFightAck > );
    handles[ 1398910108 ] = std::make_pair( "PRPlayerFightAck", msg_transfrom< PRPlayerFightAck > );
    handles[ 472110993 ] = std::make_pair( "PQPlayerFightSyn", msg_transfrom< PQPlayerFightSyn > );
    handles[ 2083684729 ] = std::make_pair( "PRFightRoundData", msg_transfrom< PRFightRoundData > );
    handles[ 1930696995 ] = std::make_pair( "PRFightEnd", msg_transfrom< PRFightEnd > );
    handles[ 409725311 ] = std::make_pair( "PQFightRecordSave", msg_transfrom< PQFightRecordSave > );
    handles[ 1025528566 ] = std::make_pair( "PQFightRecordGet", msg_transfrom< PQFightRecordGet > );
    handles[ 1176844493 ] = std::make_pair( "PRFightRecordGet", msg_transfrom< PRFightRecordGet > );
    handles[ 37267773 ] = std::make_pair( "PQFightRecordID", msg_transfrom< PQFightRecordID > );
    handles[ 1864886146 ] = std::make_pair( "PRFightRecordID", msg_transfrom< PRFightRecordID > );
    handles[ 317670076 ] = std::make_pair( "PQFightFirstShow", msg_transfrom< PQFightFirstShow > );
    handles[ 157609641 ] = std::make_pair( "PQFightSingleArenaApply", msg_transfrom< PQFightSingleArenaApply > );
    handles[ 448840913 ] = std::make_pair( "PQFightErrorLog", msg_transfrom< PQFightErrorLog > );
    handles[ 403257916 ] = std::make_pair( "PQCommonFightAuto", msg_transfrom< PQCommonFightAuto > );

    return handles;
}

