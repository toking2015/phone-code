#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CItemData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  model;
        uint32                                  locale_id;
        std::string                             name;
        uint32                                  icon;
        std::string                             icon_resource;
        uint32                                  type;
        uint32                                  client_type;
        uint32                                  subclass;
        uint32                                  equip_type;
        uint32                                  level;
        uint32                                  limitlevel;
        uint32                                  stackable;
        uint32                                  occupation;
        uint32                                  quality;
        uint32                                  bind;
        uint32                                  del_bind;
        uint32                                  due_time;
        uint32                                  unique;
        uint32                                  drop_dead;
        uint32                                  drop_logout;
        uint32                                  auto_buy_gold;
        S3UInt32                                coin;
        uint32                                  auto_sell;
        std::vector<S2UInt32>                   attrs;
        std::vector<S2UInt32>                   slave_attrs;
        uint32                                  multiuse;
        S3UInt32                                buff;
        uint32                                  bias_id;
        uint32                                  can_exchange;
        uint32                                  can_sell;
        uint32                                  can_drop;
        uint32                                  can_grant;
        uint32                                  cooltime;
        uint32                                  oddid;
        uint32                                  marktype;
        std::string                             desc;
        uint32                                  soul_score;
        uint32                                  open_cost;
        uint32                                  src_item_id;
        std::vector<S2UInt32>                   sources;
    };

	typedef std::map<uint32, SData*> UInt32ItemMap;

	CItemData();
	virtual ~CItemData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32ItemMap id_item_map;
	void Add(SData* item);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ITEMMGR_H_
