#include "proto/transfrom/transfrom_bias.h"

#include "proto/bias/SUserBias.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_bias::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;


    return handles;
}

