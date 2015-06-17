#ifndef MISC_THROW_H_
#define MISC_THROW_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdexcept>

#ifndef THROW
#define THROW(fmt, ...)\
{\
    char buff[1024];\
    snprintf(buff, sizeof(buff) - 1, fmt, ##__VA_ARGS__);\
    throw std::runtime_error(buff);\
}
#endif  //THROW

#endif  //MISC_THROW_H_
