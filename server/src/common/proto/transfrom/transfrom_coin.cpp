#include "proto/transfrom/transfrom_coin.h"

#include "proto/coin/SUserCoin.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_coin::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;


    return handles;
}

