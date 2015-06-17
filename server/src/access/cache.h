#ifndef _ACCESS_CACHE_H_
#define _ACCESS_CACHE_H_

#include "common.h"

namespace cache
{

struct SChannel
{
    struct SData
    {
        uint16 cast;
        uint16 type;
        uint32 id;
    };
    //< SUserChannel >
    std::set< uint32 > user_set;
    wd::CStream stream;
    uint64 next_time;

    SChannel() : next_time(0)
    {
    }
};

//< role_id, < SUserChannel > >
std::map< uint32, std::set< uint64 > >& user_set(void);

//< SUserChannel, SCannel >
std::map< uint64, SChannel* >& channel_map(void);

uint64 channel_to_value( uint16 cast, uint16 type, uint32 id );
SChannel::SData value_to_channel( uint64 value );

//请求频道对象, 不存在即创建
SChannel* query_channel( uint64 value );

void push( uint64 value, wd::CStream& stream );
std::vector< uint64 > query_channel_list( uint32 role_id );

void set( uint32 role_id, uint64 cast );
void unset( uint32 role_id, uint64 cast );

void offline( uint32 role_id );
void online( uint32 role_id );

//处理广播, cast 0 为广播所有
void progress( uint64 value = 0 );

}// namespace cache

#endif

