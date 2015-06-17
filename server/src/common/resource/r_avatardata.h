#ifndef IMMORTAL_COMMON_RESOURCE_R_AVATARDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_AVATARDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CAvatarData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  type;
        uint32                                  model;
    };

	typedef std::map<uint32, SData*> UInt32AvatarMap;

	CAvatarData();
	virtual ~CAvatarData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32AvatarMap id_avatar_map;
	void Add(SData* avatar);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_AVATARMGR_H_
