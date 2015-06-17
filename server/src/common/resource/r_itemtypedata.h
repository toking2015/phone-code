#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMTYPEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMTYPEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CItemTypeData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  item_type;
        uint32                                  bag_type;
        std::vector<uint32>                     bag_moves;
    };

	typedef std::map<uint32, SData*> UInt32ItemTypeMap;

	CItemTypeData();
	virtual ~CItemTypeData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 item_type );
protected:
	UInt32ItemTypeMap id_itemtype_map;
	void Add(SData* itemtype);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ITEMTYPEMGR_H_
