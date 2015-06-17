#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLESUITATTRDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLESUITATTRDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleSuitAttrData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  type;
        uint32                                  cond_exp;
        uint32                                  cond_quality;
        uint32                                  cond_count;
        std::vector<S2UInt32>                   odds;
    };

	typedef std::map<uint32, SData*> UInt32TempleSuitAttrMap;

	CTempleSuitAttrData();
	virtual ~CTempleSuitAttrData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TempleSuitAttrMap id_templesuitattr_map;
	void Add(SData* templesuitattr);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLESUITATTRMGR_H_
