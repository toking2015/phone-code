#ifndef _MSG_TRANSFROM_REGISTER_H_
#define _MSG_TRANSFROM_REGISTER_H_

#include "proto/common.h"

class class_transfrom
{
public:
    static std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > get_handles(void);
};

#endif

