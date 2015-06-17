#ifndef IMMORTAL_COMMON_RESOURCE_R_VARDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_VARDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CVarData : public CBaseData
{
public:
    struct SData
    {
        std::string                             key;
        uint32                                  flag;
    };

	typedef std::map<std::string, SData*> UInt32VarMap;

	CVarData();
	virtual ~CVarData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( std::string key );
protected:
	UInt32VarMap id_var_map;
	void Add(SData* var);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_VARMGR_H_
