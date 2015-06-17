#ifndef _PACKET_PNG2JPG_H_
#define _PACKET_PNG2JPG_H_

#include "common.h"
#include "image.h"

namespace png2jpg
{

bool split( std::string file, uint32 rgb_quality, uint32 alpha_quality );

} // namespace png2jpg

#endif
