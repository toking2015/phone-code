#include "luamgr.h"

CLuaMgr::CLuaMgr()
{
    plua = NULL;
    lua_index = 0;
}

CLuaMgr::~CLuaMgr()
{
    CloseLua();
}

lua_State* CLuaMgr::Lua()
{
    return plua;
}

bool CLuaMgr::InitLua( const char *_path )
{
    CloseLua();

    if ( NULL == plua )
    {
        plua = luaL_newstate();
        if ( NULL == plua )
        {
            LOG_DEBUG("Error in OpenLua: InitLua() == NULL");
            return false;
        }
        luaL_openlibs( plua );
        AddPathLua( _path );
        path = _path;
    }
    return true;
}

void CLuaMgr::CloseLua(void)
{
    if ( plua != NULL )
    {
        lua_close( plua );
        plua = NULL;
    }
}


void CLuaMgr::GC(void)
{
    if ( Lua() != NULL )
    {
        lua_gc( plua, LUA_GCCOLLECT, 0 );
    }
}

void CLuaMgr::GCCount()
{
    if ( Lua() != NULL )
    {
        int32 count = lua_getgccount(plua);
        LOG_DEBUG("gccount:%d",count);
    }
}

bool CLuaMgr::LoadLua( const char *LuaFile )
{
    if ( LuaFile == NULL || LuaFile[0] == '\0' )
        return false;

    if ( Lua() == NULL )
        return false;

    std::string file = path + LuaFile;

    int error = luaL_dofile( Lua(), file.c_str() );
    if ( error != 0 )
    {
        LOG_DEBUG( "Error[%d] in CLuaMgr::LoadLua: lua_dofile[%s] -> ErrorString[%s]",
            error,
            LuaFile,
            !lua_isnil( Lua(), -1 ) ? lua_tostring( Lua(), -1 ) : "" );
        return false;
    }
    GC();

    LOG_DEBUG( "LoadLua:%s", LuaFile );

    return true;
}

void CLuaMgr::AddPathLua( const char *Path )
{
    if ( Lua() == NULL || Path == NULL || Path[0] == '\0' )
        return;

    std::string newpath;
    uint32 top = lua_gettop( Lua() );
    lua_getglobal( Lua(), "package" );
    lua_getfield( Lua(), -1, "path" );
    newpath = std::string( lua_tostring( Lua(), -1 ) ) +";" + Path + "?.lua;";
    lua_pushstring( Lua(), newpath.c_str() );
    lua_setfield( Lua(), -3, "path" );
    lua_settop( Lua(), top );
}


void CLuaMgr::AddGlobalVal( const char *key, const char *val )
{
    if ( Lua() == NULL || key == NULL || val == '\0' )
        return;
    uint32 top = lua_gettop( Lua() );
    lua_pushstring( Lua(), val );
    lua_setglobal( Lua(), key );
    lua_settop( Lua(), top );
}
