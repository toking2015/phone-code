#include "util.h"
#include <stdarg.h>

Tokens  Split(const std::string& content, const std::string rep)
{
    Tokens  tokens;
    std::string s;
    for (std::string::const_iterator iter = content.begin(); iter != content.end(); ++iter)
    {
        if (std::string::npos == rep.find(*iter))
        {
            s += *iter;
            continue;
        }
        if (!s.empty())
        {
            tokens.push_back(s);
            s.clear();
        }
    }
    if (!s.empty())
    {
        tokens.push_back(s);
        s.clear();
    }

    return tokens;
}

bool IsSameDay(time_t time1, time_t time2)
{
    struct tm tm1, tm2;
    wd::localtime_r(tm1, time1);
    wd::localtime_r(tm2, time2);

    return (tm1.tm_year == tm2.tm_year) && (tm1.tm_yday== tm2.tm_yday);
//    return (tm1.tm_year == tm2.tm_year) && (tm1.tm_mon == tm2.tm_mon) && (tm1.tm_mday == tm2.tm_mday);
}

uint32 GetSecondsToNextDay(time_t start_time)
{
    struct tm tm1;
    wd::localtime_r(tm1, start_time);

    tm1.tm_sec = tm1.tm_min = tm1.tm_hour = 0;

    tm1.tm_mday += 1;

    return (uint32)( mktime(&tm1) - start_time );
}

uint32 GetSubDay (time_t time1, time_t time2)
{
    if ( time1 >= time2 )
        return 0;
    struct tm tm1, tm2;
    wd::localtime_r(tm1, time1);
    wd::localtime_r(tm2, time2);
    tm1.tm_hour = tm2.tm_hour = 0;
    tm1.tm_min = tm2.tm_min = 0;
    tm1.tm_sec = tm2.tm_sec = 0;
    uint32 _time1 = mktime(&tm1);
    uint32 _time2 = mktime(&tm2);
    return _time2/(3600*24) - _time1/(3600*24);
}

uint32 StringToTimestamp(const char*  time_str)
{
    tm tm_time = {0};
    sscanf
    (
        time_str,
        "%u/%u/%u %u:%u:%u",
        &tm_time.tm_year, &tm_time.tm_mon, &tm_time.tm_mday, &tm_time.tm_hour, &tm_time.tm_min, &tm_time.tm_sec
    );

    tm_time.tm_mon -= 1;
    tm_time.tm_year -= 1900;
    return (uint32)mktime( &tm_time );
}

int32 GetWeekday(time_t time1)
{
    struct tm tm1;
    wd::localtime_r(tm1, time1);
    return tm1.tm_wday;
}

uint32 zero_time( time_t time )
{
    struct tm t_tm;
    wd::localtime_r( t_tm, time );

    t_tm.tm_hour = 0;
    t_tm.tm_min = 0;
    t_tm.tm_sec = 0;

    return (uint32)mktime( &t_tm );
}

std::string time2str( uint32 time/* = (uint32)time(NULL)*/ )
{
    struct tm t_tm = {0};
    time_t t_time = time;

    localtime_r( &t_time, &t_tm );

    return strprintf("%d-%.2d-%.2d %.2d:%.2d:%.2d",
        t_tm.tm_year + 1900, t_tm.tm_mon + 1, t_tm.tm_mday, t_tm.tm_hour, t_tm.tm_min, t_tm.tm_sec );
}

std::string ip2str( uint32 ip )
{
    return strprintf("%hhu.%hhu.%hhu.%hhu",
        ( ip >> 24 ) & 0xFF, ( ip >> 16 ) & 0xFF, ( ip >> 8 ) & 0xFF, ip & 0xFF );
}

std::string strprintf( const char* format, ... )
{
    std::string str;

    int32 length = 0;
    {
        va_list args;
        va_start(args, format);
        length = vsnprintf( NULL, 0, format, args );
        va_end(args);
    }

    if ( length <= 0 )
        return str;

    va_list args;
    va_start(args, format);

    str.resize( length );
    vsprintf( &str[0], format, args );

    va_end(args);

    return str;
}

uint32 GetWeekZeroTime(time_t time_now)
{
    struct tm t_tm;
    wd::localtime_r( t_tm, time_now );

    t_tm.tm_hour = 0;
    t_tm.tm_min = 0;
    t_tm.tm_sec = 0;

    int week_day = t_tm.tm_wday == 0 ? 7 : t_tm.tm_wday;
    return (uint32)mktime(&t_tm) - (week_day - 1) * 86400;
}
