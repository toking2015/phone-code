#ifndef _MSG_TRANSFROM_REGISTER_present_H_
#define _MSG_TRANSFROM_REGISTER_present_H_

#include "proto/common.h"

class class_transfrom_present
{
public:
    template< typename T >
    static SMsgHead* msg_transfrom( wd::CStream& stream )
    {
        T *msg = new T;

        if ( !msg->read( stream ) )
        {
            delete msg;
            return NULL;
        }

        return msg;
    }

    static std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > get_handles(void);
};

#endif

