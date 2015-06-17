#ifndef IMMORTAL_COMMON_RESOURCE_R_OPENTARGETDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_OPENTARGETDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class COpenTargetData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  day;
        uint32                                  id;
        uint32                                  a_type;
        uint32                                  if_type;
        uint32                                  if_value_1;
        uint32                                  if_value_2;
        std::vector<S3UInt32>                   item;
        S3UInt32                                coin_1;
        std::vector<S3UInt32>                   reward;
        std::string                             name;
        std::string                             desc;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32OpenTargetMap;

	COpenTargetData();
	virtual ~COpenTargetData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 day, uint32 id );

protected:
	UInt32OpenTargetMap id_opentarget_map;
	void Add(SData* opentarget);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_OPENTARGETMGR_H_
