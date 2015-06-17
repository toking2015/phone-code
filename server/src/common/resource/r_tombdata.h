#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTombData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  monster_id;
        uint32                                  ratio;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32TombMap;

	CTombData();
	virtual ~CTombData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TombMap id_tomb_map;
	void Add(SData* tomb);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOMBMGR_H_
