#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_singlearenabattlerewardext.h"

uint32 CSingleArenaBattleRewardExt::GetReward( uint32 first, uint32 second )
{
    uint32 value = 0;

    uint32 Ti = 0;
    uint32 Tj = 0;

    for( UInt32SingleArenaBattleRewardMap::iterator iter = id_singlearenabattlereward_map.begin();
        iter != id_singlearenabattlereward_map.end();
        ++iter )
    {
        if ( first >= iter->second->field_b && first <= iter->second->field_e )
            Ti = iter->first;

        if ( second >= iter->second->field_b && second <= iter->second->field_e )
            Tj = iter->first;

        if( Ti > 0 && Tj > 0 )
            break;
    }

    if ( Ti < Tj )
        return value;

    SData *pdata_i = Find( Ti );
    SData *pdata_j = Find( Tj );

    if ( !pdata_i || !pdata_j )
        return value;

    if( Ti == Tj )
    {
        if( pdata_i->field_b == pdata_i->field_e )
            return value;
        else
        {
            value = ( first - second ) * pdata_i->field_r / 10000;

            if ( value == 0 )
                value = 1;

            return value;
        }
    }
    else
    {
        if( pdata_i->field_b == pdata_i->field_e )
        {
            for( uint32 i = Tj; i < Ti; ++i )
            {
                pdata_j = Find( i );
                if ( pdata_j )
                    value += pdata_j->field_y;

                if ( value == 0 )
                    value = 1;
            }
        }
        else
        {
            if( pdata_j->field_b == pdata_j->field_e )
            {
                value += ( first - pdata_i->field_b ) * pdata_i->field_r / 10000;

                for( uint32 i = Tj; i < Ti; ++i )
                {
                    pdata_i = Find( i );
                    if ( pdata_i )
                        value += pdata_i->field_y;

                    if ( value == 0 )
                        value = 1;
                }
            }
            else
            {
                value += ( first - pdata_i->field_b ) * pdata_i->field_r / 10000;
                value += ( pdata_j->field_e - second ) * pdata_j->field_r / 10000;

                for( uint32 i = Tj + 1; i < Ti; ++i )
                {
                    pdata_i = Find( i );
                    if ( pdata_i )
                        value += pdata_i->field_y;
                }

                if ( value == 0 )
                    value = 1;
            }
        }
    }

    return value;
}

