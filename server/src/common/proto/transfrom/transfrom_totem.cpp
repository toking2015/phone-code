#include "proto/transfrom/transfrom_totem.h"

#include "proto/totem/STotem.h"
#include "proto/totem/STotemGlyph.h"
#include "proto/totem/STotemInfo.h"
#include "proto/totem/PQTotemInfo.h"
#include "proto/totem/PRTotemInfo.h"
#include "proto/totem/PQTotemActivate.h"
#include "proto/totem/PRTotemActivate.h"
#include "proto/totem/PQTotemBless.h"
#include "proto/totem/PRTotemBless.h"
#include "proto/totem/PQTotemAddEnergy.h"
#include "proto/totem/PRTotemAddEnergy.h"
#include "proto/totem/PQTotemAccelerate.h"
#include "proto/totem/PRTotemAccelerate.h"
#include "proto/totem/PQTotemGlyphMerge.h"
#include "proto/totem/PRTotemGlyphMerge.h"
#include "proto/totem/PQTotemGlyphEmbed.h"
#include "proto/totem/PRTotemGlyphEmbed.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_totem::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 414732507 ] = std::make_pair( "PQTotemInfo", msg_transfrom< PQTotemInfo > );
    handles[ 2008807582 ] = std::make_pair( "PRTotemInfo", msg_transfrom< PRTotemInfo > );
    handles[ 936233025 ] = std::make_pair( "PQTotemActivate", msg_transfrom< PQTotemActivate > );
    handles[ 1522640888 ] = std::make_pair( "PRTotemActivate", msg_transfrom< PRTotemActivate > );
    handles[ 402450518 ] = std::make_pair( "PQTotemBless", msg_transfrom< PQTotemBless > );
    handles[ 1929801727 ] = std::make_pair( "PRTotemBless", msg_transfrom< PRTotemBless > );
    handles[ 624722301 ] = std::make_pair( "PQTotemAddEnergy", msg_transfrom< PQTotemAddEnergy > );
    handles[ 1996672069 ] = std::make_pair( "PRTotemAddEnergy", msg_transfrom< PRTotemAddEnergy > );
    handles[ 261979214 ] = std::make_pair( "PQTotemAccelerate", msg_transfrom< PQTotemAccelerate > );
    handles[ 1616213530 ] = std::make_pair( "PRTotemAccelerate", msg_transfrom< PRTotemAccelerate > );
    handles[ 763950635 ] = std::make_pair( "PQTotemGlyphMerge", msg_transfrom< PQTotemGlyphMerge > );
    handles[ 1411759523 ] = std::make_pair( "PRTotemGlyphMerge", msg_transfrom< PRTotemGlyphMerge > );
    handles[ 476898429 ] = std::make_pair( "PQTotemGlyphEmbed", msg_transfrom< PQTotemGlyphEmbed > );
    handles[ 1323933723 ] = std::make_pair( "PRTotemGlyphEmbed", msg_transfrom< PRTotemGlyphEmbed > );

    return handles;
}

