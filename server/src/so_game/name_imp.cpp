#include "name_imp.h"
#include "name_dc.h"

#include "common.h"

namespace name
{

std::string random_name(void)
{
    uint32 dic_len_1 = sizeof( dic_name_1 ) / sizeof( char* );
    uint32 dic_len_2 = sizeof( dic_name_2 ) / sizeof( char* );

    uint32 dic_idx_1 = TRand( (uint32)0, dic_len_1 );
    uint32 dic_idx_2 = TRand( (uint32)0, dic_len_2 );

    return std::string( dic_name_1[ dic_idx_1 ] )
        + std::string( dic_name_2[ dic_idx_2 ] );
}

} // namespace name
