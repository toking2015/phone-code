#ifndef IMMORTAL_COMMON_RESOURCE_R_BIASDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BIASDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBiasData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  begin_count;
        uint32                                  must_count;
        uint32                                  begin_factor;
        uint32                                  add_factor;
        uint32                                  day_count;
        uint32                                  back_id;
    };

	typedef std::map<uint32, SData*> UInt32BiasMap;

	CBiasData();
	virtual ~CBiasData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32BiasMap id_bias_map;
	void Add(SData* bias);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BIASMGR_H_
