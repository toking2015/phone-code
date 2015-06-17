#ifndef _IMMORTAL_GAMESVR_NAME_IMP_H_
#define _IMMORTAL_GAMESVR_NAME_IMP_H_

#include "common.h"

namespace name
{

//承机生成一个名称, 外部逻辑需要排除名称冲突
std::string random_name(void);

} // namespace name

#endif

