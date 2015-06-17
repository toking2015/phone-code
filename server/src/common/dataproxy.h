#ifndef _COMMON_DATAPROXY_H_
#define _COMMON_DATAPROXY_H_

#include "common.h"

class CDataProxy
{
public:
    CDataProxy();
    virtual ~CDataProxy();

    virtual void trans_to_stream( wd::CStream& stream ) = 0;
    virtual void trans_to_db( wd::CStream& stream ) = 0;

public:
    static void register_module( std::string& name, CDataProxy* pointer );
    static void trans_to_stream_and_reset(void);
    static void trans_to_db_and_reset(void);
};

#endif

