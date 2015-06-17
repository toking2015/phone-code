#ifndef _FIGHTSVR_FIGHTLUA_H_
#define _FIGHTSVR_FIGHTLUA_H_

extern "C"
{
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

namespace lua
{
    int CPrint( lua_State *L );
    int CRand( lua_State *L );

    void LuaInterfaceInit( lua_State *L );
    void LuaReloadAll(void);

    void clearlog();
    void printlog();
} // namespace lua

#endif


