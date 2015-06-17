#ifndef _COMMON_DECLARE_H_
#define _COMMON_DECLARE_H_

extern "C" {
#include "lua.h"
}

#include "common.h"

namespace declare
{

std::map< std::string, uint32 >& name_handles(void);
std::map< uint32, std::string >& cmd_handles(void);

int32 declare_base_reg( lua_State* L );
int32 declare_base_rand( lua_State* L );

} // namespace declare

#endif

