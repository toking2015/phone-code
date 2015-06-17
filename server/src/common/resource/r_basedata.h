#ifndef _IMMORTAL_BASEDATA_RESOURCE_H_
#define _IMMORTAL_BASEDATA_RESOURCE_H_

#include "common.h"

class CBaseData
{
public:
    CBaseData(){}
    virtual ~CBaseData(){}
};

class CResData
{
private:
    std::vector<CBaseData*> p_datas;
public:
    void insert(CBaseData* p);
    static void data_free(void);
};

#define theResDataMgr TSignleton< CResData >::Ref()

#endif

