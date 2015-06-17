#ifndef _COMMON_OUTPUT_H_
#define _COMMON_OUTPUT_H_

#include "common.h"

namespace output
{

int32 open( std::string name, uint32 time );
void write( std::string& name, std::string& text, uint32 time );
void close( std::string name );
void close_limit_time( uint32 limit_time );

} // namespace output

#endif

