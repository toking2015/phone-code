#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMMERGEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMMERGEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CItemMergeData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  type;
        uint32                                  limit_level;
        uint32                                  item_id;
        uint32                                  package_id;
        S3UInt32                                dst_item;
        std::vector<S3UInt32>                   materials;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32ItemMergeMap;

	CItemMergeData();
	virtual ~CItemMergeData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32ItemMergeMap id_itemmerge_map;
	void Add(SData* itemmerge);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ITEMMERGEMGR_H_
