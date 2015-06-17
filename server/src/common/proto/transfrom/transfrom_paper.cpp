#include "proto/transfrom/transfrom_paper.h"

#include "proto/paper/SUserCopyMaterial.h"
#include "proto/paper/PQPaperLevelUp.h"
#include "proto/paper/PQPaperForget.h"
#include "proto/paper/PQPaperCreate.h"
#include "proto/paper/PRPaperCreate.h"
#include "proto/paper/PQPaperCollect.h"
#include "proto/paper/PRPaperCopyMaterialPoint.h"
#include "proto/paper/PRPaperCollect.h"
#include "proto/paper/PRPaperCopyMaterial.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_paper::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1036717831 ] = std::make_pair( "PQPaperLevelUp", msg_transfrom< PQPaperLevelUp > );
    handles[ 125886294 ] = std::make_pair( "PQPaperForget", msg_transfrom< PQPaperForget > );
    handles[ 795415437 ] = std::make_pair( "PQPaperCreate", msg_transfrom< PQPaperCreate > );
    handles[ 1861819907 ] = std::make_pair( "PRPaperCreate", msg_transfrom< PRPaperCreate > );
    handles[ 893714413 ] = std::make_pair( "PQPaperCollect", msg_transfrom< PQPaperCollect > );
    handles[ 1793480676 ] = std::make_pair( "PRPaperCopyMaterialPoint", msg_transfrom< PRPaperCopyMaterialPoint > );
    handles[ 1843830073 ] = std::make_pair( "PRPaperCollect", msg_transfrom< PRPaperCollect > );
    handles[ 1531515678 ] = std::make_pair( "PRPaperCopyMaterial", msg_transfrom< PRPaperCopyMaterial > );

    return handles;
}

