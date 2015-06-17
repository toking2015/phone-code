#ifndef IMMORTAL_COMMON_RESOURCE_R_VAREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_VAREXT_H_

#include "r_vardata.h"

class CVarExt : public CVarData
{
private:
    //< param_count, < key, data > >
    std::map< int32, std::map< std::string, SData* > > match_var_map;

public:
    ~CVarExt();

    void LoadData(void);
    void ClearData(void);

    CVarData::SData* Find( std::string key );
};

#define theVarExt TSignleton<CVarExt>::Ref()
#endif
