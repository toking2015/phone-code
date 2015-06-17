#include "proto/transfrom/transfrom_equip.h"

#include "proto/equip/SUserEquipGrade.h"
#include "proto/equip/PQEquipMerge.h"
#include "proto/equip/PREquipMerge.h"
#include "proto/equip/PQEquipReplace.h"
#include "proto/equip/PREquipReplace.h"
#include "proto/equip/PQEquipSelectSuit.h"
#include "proto/equip/PREquipSelectSuits.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_equip::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 499293600 ] = std::make_pair( "PQEquipMerge", msg_transfrom< PQEquipMerge > );
    handles[ 1112608984 ] = std::make_pair( "PREquipMerge", msg_transfrom< PREquipMerge > );
    handles[ 109236104 ] = std::make_pair( "PQEquipReplace", msg_transfrom< PQEquipReplace > );
    handles[ 1478196340 ] = std::make_pair( "PREquipReplace", msg_transfrom< PREquipReplace > );
    handles[ 479388940 ] = std::make_pair( "PQEquipSelectSuit", msg_transfrom< PQEquipSelectSuit > );
    handles[ 1083849332 ] = std::make_pair( "PREquipSelectSuits", msg_transfrom< PREquipSelectSuits > );

    return handles;
}

