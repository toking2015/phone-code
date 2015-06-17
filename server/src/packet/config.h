#ifndef _PACKET_CONFIG_H_
#define _PACKET_CONFIG_H_

#include "common.h"

struct SConfig
{
    struct
    {
        bool        used;

        uint32      rgb_quality;
        uint32      alpha_quality;

    }png2jpg;

    struct
    {
        std::vector< std::string > array;
    }ignore;

    SConfig()
    {
        png2jpg.used            = false;
    }
};

namespace config
{

SConfig setup( int32 depth, std::string& path );

} // namespace config

#endif
