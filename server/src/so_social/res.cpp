#include "misc.h"
#include "jsonconfig.h"
#include "settings.h"
#include "master.h"
#include "resource/r_marketext.h"

SO_LOAD( res_interface_register )
{
    //dir目录赋值
    CJson::dir = settings::json()[ "extras_dir" ].asString() + "/xls/";

    //设置theRes的析构函数
    theMaster._resource_reg_free = CResData::data_free;

    theMarketExt.LoadData();
}
