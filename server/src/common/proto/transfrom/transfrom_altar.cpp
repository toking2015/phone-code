#include "proto/transfrom/transfrom_altar.h"

#include "proto/altar/SAltarInfo.h"
#include "proto/altar/PQAltarInfo.h"
#include "proto/altar/PRAltarInfo.h"
#include "proto/altar/PQAltarLottery.h"
#include "proto/altar/PRAltarLottery.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_altar::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 11246124 ] = std::make_pair( "PQAltarInfo", msg_transfrom< PQAltarInfo > );
    handles[ 2075834311 ] = std::make_pair( "PRAltarInfo", msg_transfrom< PRAltarInfo > );
    handles[ 512180379 ] = std::make_pair( "PQAltarLottery", msg_transfrom< PQAltarLottery > );
    handles[ 1154904222 ] = std::make_pair( "PRAltarLottery", msg_transfrom< PRAltarLottery > );

    return handles;
}

