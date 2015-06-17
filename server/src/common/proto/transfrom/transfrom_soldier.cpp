#include "proto/transfrom/transfrom_soldier.h"

#include "proto/soldier/SSoldierSkill.h"
#include "proto/soldier/SUserSoldier.h"
#include "proto/soldier/PQSoldierList.h"
#include "proto/soldier/PRSoldierList.h"
#include "proto/soldier/PQSoldierAdd.h"
#include "proto/soldier/PRSoldierSet.h"
#include "proto/soldier/PQSoldierDel.h"
#include "proto/soldier/PQSoldierMove.h"
#include "proto/soldier/PQSoldierQualityAddXp.h"
#include "proto/soldier/PQSoldierQualityUp.h"
#include "proto/soldier/PQSoldierLvUp.h"
#include "proto/soldier/PQSoldierStarUp.h"
#include "proto/soldier/PQSoldierRecruit.h"
#include "proto/soldier/PRSoldierRecruit.h"
#include "proto/soldier/PQSoldierEquip.h"
#include "proto/soldier/PQSoldierSkillReset.h"
#include "proto/soldier/PQSoldierSkillLvUp.h"
#include "proto/soldier/PQSoldierEquipExt.h"
#include "proto/soldier/PRSoldierEquipExt.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_soldier::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 961013796 ] = std::make_pair( "PQSoldierList", msg_transfrom< PQSoldierList > );
    handles[ 1666924443 ] = std::make_pair( "PRSoldierList", msg_transfrom< PRSoldierList > );
    handles[ 717748738 ] = std::make_pair( "PQSoldierAdd", msg_transfrom< PQSoldierAdd > );
    handles[ 1949745294 ] = std::make_pair( "PRSoldierSet", msg_transfrom< PRSoldierSet > );
    handles[ 1026501369 ] = std::make_pair( "PQSoldierDel", msg_transfrom< PQSoldierDel > );
    handles[ 61793682 ] = std::make_pair( "PQSoldierMove", msg_transfrom< PQSoldierMove > );
    handles[ 374239288 ] = std::make_pair( "PQSoldierQualityAddXp", msg_transfrom< PQSoldierQualityAddXp > );
    handles[ 878179539 ] = std::make_pair( "PQSoldierQualityUp", msg_transfrom< PQSoldierQualityUp > );
    handles[ 915576268 ] = std::make_pair( "PQSoldierLvUp", msg_transfrom< PQSoldierLvUp > );
    handles[ 212308155 ] = std::make_pair( "PQSoldierStarUp", msg_transfrom< PQSoldierStarUp > );
    handles[ 47531286 ] = std::make_pair( "PQSoldierRecruit", msg_transfrom< PQSoldierRecruit > );
    handles[ 1678160619 ] = std::make_pair( "PRSoldierRecruit", msg_transfrom< PRSoldierRecruit > );
    handles[ 949928079 ] = std::make_pair( "PQSoldierEquip", msg_transfrom< PQSoldierEquip > );
    handles[ 56411694 ] = std::make_pair( "PQSoldierSkillReset", msg_transfrom< PQSoldierSkillReset > );
    handles[ 9167997 ] = std::make_pair( "PQSoldierSkillLvUp", msg_transfrom< PQSoldierSkillLvUp > );
    handles[ 76490040 ] = std::make_pair( "PQSoldierEquipExt", msg_transfrom< PQSoldierEquipExt > );
    handles[ 1961337467 ] = std::make_pair( "PRSoldierEquipExt", msg_transfrom< PRSoldierEquipExt > );

    return handles;
}

