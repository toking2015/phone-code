#ifndef _COMMON_LOG_H_
#define _COMMON_LOG_H_

#include <log4cxx/logger.h>
#include <log4cxx/propertyconfigurator.h>
#include <log4cxx/helpers/exception.h>
#include "common.h"

class CLog4cxx
{
public:
    log4cxx::LoggerPtr logger;

public:
    static void read(const char* file);
    static char* thread_buffer_alloc( uint32 size );
};
#define theLog TSignleton<CLog4cxx >::Ref()

#define LOG_DEBUG(fmt, ...)\
    if ( theLog.logger && theLog.logger->isDebugEnabled() )\
    {\
        uint32 _log_len = snprintf( NULL, 0, fmt, ##__VA_ARGS__ ) + 1;\
        char* _log_buff = theLog.thread_buffer_alloc( _log_len );\
        snprintf( _log_buff, _log_len, fmt, ##__VA_ARGS__);\
        printf( "%s\n", _log_buff );\
        LOG4CXX_DEBUG(theLog.logger, _log_buff);\
    }
#define LOG_INFO(fmt, ...)\
    if ( theLog.logger && theLog.logger->isInfoEnabled() )\
    {\
        uint32 _log_len = snprintf( NULL, 0, fmt, ##__VA_ARGS__ ) + 1;\
        char* _log_buff = theLog.thread_buffer_alloc( _log_len );\
        snprintf( _log_buff, _log_len, fmt, ##__VA_ARGS__);\
        printf( "%s\n", _log_buff );\
        LOG4CXX_INFO(theLog.logger, _log_buff);\
   }
#define LOG_WARN(fmt, ...)\
    if ( theLog.logger && theLog.logger->isWarnEnabled() )\
    {\
        uint32 _log_len = snprintf( NULL, 0, fmt, ##__VA_ARGS__ ) + 1;\
        char* _log_buff = theLog.thread_buffer_alloc( _log_len );\
        snprintf( _log_buff, _log_len, fmt, ##__VA_ARGS__);\
        printf( "%s\n", _log_buff );\
        LOG4CXX_WARN(theLog.logger, _log_buff);\
    }
#define LOG_ERROR(fmt, ...)\
    if ( theLog.logger && theLog.logger->isErrorEnabled() )\
    {\
        uint32 _log_len = snprintf( NULL, 0, fmt, ##__VA_ARGS__ ) + 1;\
        char* _log_buff = theLog.thread_buffer_alloc( _log_len );\
        snprintf( _log_buff, _log_len, fmt, ##__VA_ARGS__);\
        printf( "%s\n", _log_buff );\
        LOG4CXX_ERROR(theLog.logger, _log_buff);\
    }

#endif //_COMMON_LOG_H_
