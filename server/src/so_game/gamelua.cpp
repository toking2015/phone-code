#include "gamelua.h"
#include "log.h"
#include "luamgr.h"
#include "luaseq.h"
#include "misc.h"
#include "declare.h"
#include "settings.h"
#include "resource/r_effectext.h"
#include "fight_imp.h"

namespace lua
{

//调用LOGDEBUG
int CPrint( lua_State *L )
{
	if ( lua_gettop(L) != 1 || !lua_isstring( L, -1 ) )
	{
		return 0;
	}

    //Gamesvr这边不打印
    //LOG_INFO(lua_tostring( L, -1 ));

	return 0;
}

//外部重载
void LuaInterfaceInit( lua_State *L )
{
    luaL_Reg System_Interface[] =
    {
        { "CPrint",             CPrint                      },
        { "CRand",              declare::declare_base_rand  },
        { "CReg",               declare::declare_base_reg   },
        //一定要以两个NULL为结束
        { NULL, NULL }
    };
	luaL_register( L, "System",			System_Interface );
}

void LuaLoad(void)
{
    std::string lua_path = settings::json()[ "lua_path" ].asString();
    std::string extras_dir = settings::json()[ "extras_dir" ].asString();
    theLuaMgr.InitLua(lua_path.c_str());
    theLuaMgr.AddGlobalVal("g_filePath", extras_dir.c_str());
    lua::LuaInterfaceInit( theLuaMgr.Lua() );
    theLuaMgr.LoadLua("lua/server/SvrConfig.lua");
    theLuaMgr.LoadLua("lua/server/BattleLogic.lua");
}

}// namespace lua

SO_LOAD( lua_interface_register )
{
    lua::LuaLoad();
    fight::SetFightData();
}

