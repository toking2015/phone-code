#include "misc.h"
#include "singlearena_imp.h"
#include "proto/singlearena.h"
#include "proto/constant.h"
#include "local.h"
#include "log.h"


MSG_FUNC( PQSingleArenaSave )
{
    singlearena::SaveData( msg.set_type, msg.data );
}

MSG_FUNC( PQSingleArenaRankLoad )
{
    singlearena::LoadData();
}

MSG_FUNC( PQSingleArenaLogSave )
{
    singlearena::SaveLog( msg.target_id, msg.list );
}

MSG_FUNC( PQSingleArenaLogLoad )
{
    singlearena::LoadLog();
}

