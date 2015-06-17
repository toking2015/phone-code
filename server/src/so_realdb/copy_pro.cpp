#include "misc.h"
#include "copy_imp.h"
#include "proto/copy.h"
#include "proto/constant.h"
#include "local.h"
#include "log.h"


MSG_FUNC( PQCopyFightLog )
{
    copy::LoadLog();
}

MSG_FUNC( PQCopyFightLogSave )
{
    copy::SaveLog( msg.copy_id, msg.list );
}

