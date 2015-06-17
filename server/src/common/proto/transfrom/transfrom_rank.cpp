#include "proto/transfrom/transfrom_rank.h"

#include "proto/rank/SRankInfo.h"
#include "proto/rank/SRankData.h"
#include "proto/rank/CRank.h"
#include "proto/rank/CRankCenter.h"
#include "proto/rank/PQRankCopySave.h"
#include "proto/rank/PQRankLoad.h"
#include "proto/rank/PRRankLoad.h"
#include "proto/rank/PQRankIndex.h"
#include "proto/rank/PRRankIndex.h"
#include "proto/rank/PQRankList.h"
#include "proto/rank/PQRankListType.h"
#include "proto/rank/PRRankList.h"
#include "proto/rank/PRRankClearData.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_rank::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 479530750 ] = std::make_pair( "PQRankCopySave", msg_transfrom< PQRankCopySave > );
    handles[ 810078193 ] = std::make_pair( "PQRankLoad", msg_transfrom< PQRankLoad > );
    handles[ 2011706770 ] = std::make_pair( "PRRankLoad", msg_transfrom< PRRankLoad > );
    handles[ 534066083 ] = std::make_pair( "PQRankIndex", msg_transfrom< PQRankIndex > );
    handles[ 1385163042 ] = std::make_pair( "PRRankIndex", msg_transfrom< PRRankIndex > );
    handles[ 612777078 ] = std::make_pair( "PQRankList", msg_transfrom< PQRankList > );
    handles[ 164901211 ] = std::make_pair( "PQRankListType", msg_transfrom< PQRankListType > );
    handles[ 2140059588 ] = std::make_pair( "PRRankList", msg_transfrom< PRRankList > );
    handles[ 1386335833 ] = std::make_pair( "PRRankClearData", msg_transfrom< PRRankClearData > );

    return handles;
}

