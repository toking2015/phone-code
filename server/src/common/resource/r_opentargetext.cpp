#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_opentargetext.h"

void    COpenTargetExt::FindList( uint32 day, std::vector< COpenTargetData::SData* > &list )
{
	std::map<uint32, COpenTargetData::SData*> map = id_opentarget_map[day];
    for( std::map<uint32, COpenTargetData::SData*>::iterator iter = map.begin();
        iter != map.end();
        ++iter )
    {
        list.push_back( iter->second );
    }
}

