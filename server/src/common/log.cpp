#include "log.h"

#include <sys/types.h>

#define __LOG4CXX_WRITE__

#ifdef GPROF
#ifdef __LOG4CXX_WRITE__
#undef __LOG4CXX_WRITE__
#endif //__LOG4CXX_WRITE__
#endif //GPROF

void CLog4cxx::read(const char* file)
{
#ifdef __LOG4CXX_WRITE__
    log4cxx::PropertyConfigurator::configure(file);
#endif

    theLog.logger = log4cxx::Logger::getRootLogger();
}

char* CLog4cxx::thread_buffer_alloc( uint32 size )
{
    uint32 tid = (uint32)syscall(__NR_gettid);

    static std::map< uint32, std::vector<char> > thread_buff_map;
    std::vector< char >& buff = thread_buff_map[ tid ];

    if ( buff.size() < size )
        buff.resize( size );

    return &buff[0];
}

#ifdef __LOG4CXX_WRITE__
#undef __LOG4CXX_WRITE__
#endif
