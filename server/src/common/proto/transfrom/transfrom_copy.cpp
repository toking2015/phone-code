#include "proto/transfrom/transfrom_copy.h"

#include "proto/copy/SUserCopy.h"
#include "proto/copy/SCopyLog.h"
#include "proto/copy/SCopyFightLog.h"
#include "proto/copy/SAreaLog.h"
#include "proto/copy/SCopyMopup.h"
#include "proto/copy/SCopyBossFight.h"
#include "proto/copy/CCopy.h"
#include "proto/copy/PQCopyOpen.h"
#include "proto/copy/PRCopyOpen.h"
#include "proto/copy/PRCopyData.h"
#include "proto/copy/PQCopyClose.h"
#include "proto/copy/PRCopyClose.h"
#include "proto/copy/PQCopyCommitEvent.h"
#include "proto/copy/PRCopyCommitEvent.h"
#include "proto/copy/PQCopyCommitEventFight.h"
#include "proto/copy/PRCopyCommitEventFight.h"
#include "proto/copy/PQCopyRefurbish.h"
#include "proto/copy/PRCopyRefurbish.h"
#include "proto/copy/PQCopyLog.h"
#include "proto/copy/PRCopyLog.h"
#include "proto/copy/PQCopyLogList.h"
#include "proto/copy/PRCopyLogList.h"
#include "proto/copy/PQCopyBossFight.h"
#include "proto/copy/PRCopyBossFight.h"
#include "proto/copy/PQCopyBossFightCommit.h"
#include "proto/copy/PRCopyAreaData.h"
#include "proto/copy/PQCopyAreaPresentTake.h"
#include "proto/copy/PRCopyAreaPresentTake.h"
#include "proto/copy/PQCopyBossMopup.h"
#include "proto/copy/PRCopyBossMopup.h"
#include "proto/copy/PQCopyMopupReset.h"
#include "proto/copy/PRCopyMopupData.h"
#include "proto/copy/PQCopyFightLog.h"
#include "proto/copy/PRCopyFightLog.h"
#include "proto/copy/PQCopyFightLogLoad.h"
#include "proto/copy/PRCopyFightLogLoad.h"
#include "proto/copy/PQCopyFightLogSave.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_copy::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 443612719 ] = std::make_pair( "PQCopyOpen", msg_transfrom< PQCopyOpen > );
    handles[ 1180545869 ] = std::make_pair( "PRCopyOpen", msg_transfrom< PRCopyOpen > );
    handles[ 2097723839 ] = std::make_pair( "PRCopyData", msg_transfrom< PRCopyData > );
    handles[ 684499077 ] = std::make_pair( "PQCopyClose", msg_transfrom< PQCopyClose > );
    handles[ 1145076953 ] = std::make_pair( "PRCopyClose", msg_transfrom< PRCopyClose > );
    handles[ 463078305 ] = std::make_pair( "PQCopyCommitEvent", msg_transfrom< PQCopyCommitEvent > );
    handles[ 1829634408 ] = std::make_pair( "PRCopyCommitEvent", msg_transfrom< PRCopyCommitEvent > );
    handles[ 750802594 ] = std::make_pair( "PQCopyCommitEventFight", msg_transfrom< PQCopyCommitEventFight > );
    handles[ 1091587271 ] = std::make_pair( "PRCopyCommitEventFight", msg_transfrom< PRCopyCommitEventFight > );
    handles[ 778525585 ] = std::make_pair( "PQCopyRefurbish", msg_transfrom< PQCopyRefurbish > );
    handles[ 1260538048 ] = std::make_pair( "PRCopyRefurbish", msg_transfrom< PRCopyRefurbish > );
    handles[ 942268467 ] = std::make_pair( "PQCopyLog", msg_transfrom< PQCopyLog > );
    handles[ 1481077064 ] = std::make_pair( "PRCopyLog", msg_transfrom< PRCopyLog > );
    handles[ 729938598 ] = std::make_pair( "PQCopyLogList", msg_transfrom< PQCopyLogList > );
    handles[ 1520184157 ] = std::make_pair( "PRCopyLogList", msg_transfrom< PRCopyLogList > );
    handles[ 257944230 ] = std::make_pair( "PQCopyBossFight", msg_transfrom< PQCopyBossFight > );
    handles[ 1415847306 ] = std::make_pair( "PRCopyBossFight", msg_transfrom< PRCopyBossFight > );
    handles[ 273326454 ] = std::make_pair( "PQCopyBossFightCommit", msg_transfrom< PQCopyBossFightCommit > );
    handles[ 1607507845 ] = std::make_pair( "PRCopyAreaData", msg_transfrom< PRCopyAreaData > );
    handles[ 302285013 ] = std::make_pair( "PQCopyAreaPresentTake", msg_transfrom< PQCopyAreaPresentTake > );
    handles[ 1845809709 ] = std::make_pair( "PRCopyAreaPresentTake", msg_transfrom< PRCopyAreaPresentTake > );
    handles[ 730523402 ] = std::make_pair( "PQCopyBossMopup", msg_transfrom< PQCopyBossMopup > );
    handles[ 2079542214 ] = std::make_pair( "PRCopyBossMopup", msg_transfrom< PRCopyBossMopup > );
    handles[ 286952083 ] = std::make_pair( "PQCopyMopupReset", msg_transfrom< PQCopyMopupReset > );
    handles[ 1230975462 ] = std::make_pair( "PRCopyMopupData", msg_transfrom< PRCopyMopupData > );
    handles[ 773405342 ] = std::make_pair( "PQCopyFightLog", msg_transfrom< PQCopyFightLog > );
    handles[ 1224955052 ] = std::make_pair( "PRCopyFightLog", msg_transfrom< PRCopyFightLog > );
    handles[ 860903992 ] = std::make_pair( "PQCopyFightLogLoad", msg_transfrom< PQCopyFightLogLoad > );
    handles[ 2002119907 ] = std::make_pair( "PRCopyFightLogLoad", msg_transfrom< PRCopyFightLogLoad > );
    handles[ 252912344 ] = std::make_pair( "PQCopyFightLogSave", msg_transfrom< PQCopyFightLogSave > );

    return handles;
}

