#include "proto/transfrom/transfrom_temple.h"

#include "proto/temple/STempleGlyph.h"
#include "proto/temple/STempleGroup.h"
#include "proto/temple/STempleInfo.h"
#include "proto/temple/PQTempleInfo.h"
#include "proto/temple/PRTempleInfo.h"
#include "proto/temple/PQTempleGroupLevelUp.h"
#include "proto/temple/PRTempleGroupLevelUp.h"
#include "proto/temple/PQTempleOpenHole.h"
#include "proto/temple/PRTempleOpenHole.h"
#include "proto/temple/PQTempleEmbedGlyph.h"
#include "proto/temple/PRTempleEmbedGlyph.h"
#include "proto/temple/PQTempleGlyphTrain.h"
#include "proto/temple/PRTempleGlyphTrain.h"
#include "proto/temple/PQTempleTakeScoreReward.h"
#include "proto/temple/PRTempleTakeScoreReward.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_temple::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 892087342 ] = std::make_pair( "PQTempleInfo", msg_transfrom< PQTempleInfo > );
    handles[ 1890641118 ] = std::make_pair( "PRTempleInfo", msg_transfrom< PRTempleInfo > );
    handles[ 452599552 ] = std::make_pair( "PQTempleGroupLevelUp", msg_transfrom< PQTempleGroupLevelUp > );
    handles[ 1805247991 ] = std::make_pair( "PRTempleGroupLevelUp", msg_transfrom< PRTempleGroupLevelUp > );
    handles[ 515062735 ] = std::make_pair( "PQTempleOpenHole", msg_transfrom< PQTempleOpenHole > );
    handles[ 2030485707 ] = std::make_pair( "PRTempleOpenHole", msg_transfrom< PRTempleOpenHole > );
    handles[ 312492137 ] = std::make_pair( "PQTempleEmbedGlyph", msg_transfrom< PQTempleEmbedGlyph > );
    handles[ 1866259123 ] = std::make_pair( "PRTempleEmbedGlyph", msg_transfrom< PRTempleEmbedGlyph > );
    handles[ 198720182 ] = std::make_pair( "PQTempleGlyphTrain", msg_transfrom< PQTempleGlyphTrain > );
    handles[ 1477567015 ] = std::make_pair( "PRTempleGlyphTrain", msg_transfrom< PRTempleGlyphTrain > );
    handles[ 174141501 ] = std::make_pair( "PQTempleTakeScoreReward", msg_transfrom< PQTempleTakeScoreReward > );
    handles[ 1627535597 ] = std::make_pair( "PRTempleTakeScoreReward", msg_transfrom< PRTempleTakeScoreReward > );

    return handles;
}

