#ifndef IMMORTAL_COMMON_UTIL_H_
#define IMMORTAL_COMMON_UTIL_H_

#include "common.h"

typedef std::vector<std::string > Tokens;

//分解字符串
Tokens  Split(const std::string& content, const std::string rep);

//判断两个时间点是否属于同一天
bool IsSameDay(time_t time1, time_t time2=time(NULL));

//获得距离下一天的秒数
uint32 GetSecondsToNextDay(time_t start_time=time(NULL));

//相差几天
uint32 GetSubDay(time_t time1, time_t time2=time(NULL));

uint32 StringToTimestamp(const char*  time_str);

int32  GetWeekday(time_t time1);

//将时间截以当天00:00:00对齐
uint32 zero_time( time_t time );

//将时间格式转化为 2013-09-24 10:26:33
std::string time2str( uint32 time = (uint32)time(NULL) );

//将ip转化为 192.168.4.153
std::string ip2str( uint32 ip );

std::string strprintf( const char* format, ... );

int32 str2int( const char* str );

//取time_now周一的零点
uint32 GetWeekZeroTime(time_t time_now);

//圆桌算法, call 为求 list 元素权值的函数, sum 为已知权值总和
template<typename T, typename P>
T round_rand( std::vector<T>& list, P call, uint32 sum = 0 )
{
    if ( sum == 0 )
    {
        for ( int32 i = 0; i < (int32)list.size(); ++i )
            sum += call( list[i] );
    }

    uint32 value = TRand( (uint32)0, sum );
    for ( int32 i = 0; i < (int32)list.size(); ++i )
    {
        uint32 v = call( list[i] );
        if ( value < v )
            return list[i];

        value -= v;
    }

    //返回空? 存在异常
    return T();
}

#define TO_STRING( x ) TO_STRING1( x )
#define TO_STRING1( x ) #x

#endif  //IMMORTAL_COMMON_UTIL_H_
