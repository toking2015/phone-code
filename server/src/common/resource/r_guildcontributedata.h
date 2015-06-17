#ifndef IMMORTAL_COMMON_RESOURCE_R_GUILDCONTRIBUTEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_GUILDCONTRIBUTEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CGuildContributeData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        S3UInt32                                cost;
        uint32                                  contribute;
        std::vector<S3UInt32>                   coins;
        std::string                             name;
    };

	typedef std::map<uint32, SData*> UInt32GuildContributeMap;

	CGuildContributeData();
	virtual ~CGuildContributeData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32GuildContributeMap id_guildcontribute_map;
	void Add(SData* guildcontribute);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_GUILDCONTRIBUTEMGR_H_
