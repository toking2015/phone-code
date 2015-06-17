#include "misc.h"
#include "jsonconfig.h"
#include "settings.h"
#include "r_basedata.h"

void CResData::insert(CBaseData* p)
{
    p_datas.push_back(p);
}

void CResData::data_free(void)
{
    for( std::vector<CBaseData*>::iterator iter = theResDataMgr.p_datas.begin();
        iter != theResDataMgr.p_datas.end();
        ++iter )
    {
        delete *iter;
    }
}

