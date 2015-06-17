#ifndef IMMORTAL_COMMON_RESOURCE_R_GUILDLEVELDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_GUILDLEVELDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CGuildLevelData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  level;
        uint32                                  levelup_xp;
        uint32                                  member_count;
        uint32                                  vendible_begin;
        uint32                                  vendible_end;
    };

	typedef std::map<uint32, SData*> UInt32GuildLevelMap;

	CGuildLevelData();
	virtual ~CGuildLevelData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 level );
protected:
	UInt32GuildLevelMap id_guildlevel_map;
	void Add(SData* guildlevel);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_GUILDLEVELMGR_H_
