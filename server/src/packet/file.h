#ifndef _PACKET_FILE_H_
#define _PACKET_FILE_H_

#include "common.h"

namespace file
{

typedef void FCall( int32 depth, std::string& path, std::set< std::string >& files, std::set< std::string >& dirs );

//@path:    搜索路径( 最后一字节为/ )
//@call:    回调函数
//@depth:   内传深度( 外部不要直接传参 )
void loop( std::string path, FCall call, int32 depth = 0 );

uint32 get_size( std::string& file );
void del( std::string& file );

bool read( std::string& file, std::vector<char>& data );
bool write( std::string& file, std::vector<char>& data );

} // namespace file

#endif
