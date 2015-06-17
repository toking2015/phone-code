#ifndef IMMORTAL_COMMON_RESOURCE_R_ACHIEVEMENTGOODSDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ACHIEVEMENTGOODSDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CAchievementGoodsData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        S2UInt32                                cond;
    };

	typedef std::map<uint32, SData*> UInt32AchievementGoodsMap;

	CAchievementGoodsData();
	virtual ~CAchievementGoodsData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32AchievementGoodsMap id_achievementgoods_map;
	void Add(SData* achievementgoods);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ACHIEVEMENTGOODSMGR_H_
