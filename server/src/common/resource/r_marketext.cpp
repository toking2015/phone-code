#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_marketext.h"

CMarketExt::~CMarketExt()
{
    indices.clear();
}

CMarketExt::TEquip& CMarketExt::GetIndices(void)
{
    if ( indices.empty() )
    {
        for ( std::map<uint32, CMarketData::SData*>::iterator iter = id_market_map.begin();
            iter != id_market_map.end();
            ++iter )
        {
            CMarketData::SData* data = iter->second;

            indices[ data->type ][ data->level ][ data->group ].push_back( data );
        }
    }

    return indices;
}

std::vector< CMarketData::SData* > CMarketExt::find_custom( uint32 type, uint32 level, uint32 group )
{
    TEquip& indices = GetIndices();

    do
    {
        TEquip::iterator i = indices.find( type );
        if ( i == indices.end() )
            break;

        TLevel::iterator j = i->second.find( level );
        if ( j == i->second.end() )
            break;

        TGroup::iterator k = j->second.find( group );
        if ( k == j->second.end() )
            break;

        return k->second;
    }
    while(0);

    return std::vector< CMarketData::SData* >();
}
