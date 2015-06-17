#ifndef _COMMON_SETTINGS_H_
#define _COMMON_SETTINGS_H_

#include "common.h"
#include "jsonconfig.h"

//配置文件
namespace settings
{
    bool read( const char* file );
    CJson& json(void);
} // namespace settings

#endif

