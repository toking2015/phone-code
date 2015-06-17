#include "pro.h"
#include "misc.h"
#include "proto/server.h"
#include "fightlog_dc.h"

MSG_FUNC( PRServerClose )
{
    if ( key != local::self )
        return;

    //在这里, 网络线程, 解包线程已不可用
    theFightRecordDC.SaveFightLog();
}

