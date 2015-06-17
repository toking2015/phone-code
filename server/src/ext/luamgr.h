#ifndef IMMORTAL_COMMON_LUAMGR_H_
#define IMMORTAL_COMMON_LUAMGR_H_

#include <lua.hpp>
#include "common.h"
#include "log.h"

class CLuaMgr
{
private:
	lua_State *plua;
	int32 lua_index;
    std::string path;

public:
	CLuaMgr();
	~CLuaMgr();

    lua_State *Lua();
    void GC(void);
    void GCCount();
	bool LoadLua( const char *LuaFile );
    bool InitLua( const char *path );
    void CloseLua(void);
	void AddPathLua( const char *Path );
    void AddGlobalVal( const char *key, const char *val );
};

#define theLuaMgr TSignleton< CLuaMgr >::Ref()

#endif


