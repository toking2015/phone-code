#include "declare.h"
#include "luaseq.h"

namespace declare
{

std::map< std::string, uint32 >& name_handles(void)
{
	static std::map< std::string, uint32 > map;
	return map;
}
std::map< uint32, std::string >& cmd_handles(void)
{
	static std::map< uint32, std::string > map;
	return map;
}

std::map< std::string, std::pair< luaseq::FToStream, luaseq::FToLua > >& luaseq_method(void)
{
	static std::map< std::string, std::pair< luaseq::FToStream, luaseq::FToLua > > map;
	if ( map.empty() )
	{
		map[ "int8" ] = std::make_pair( luaseq::to_stream_int<int8>, luaseq::to_lua_int<int8> );
		map[ "uint8" ] = std::make_pair( luaseq::to_stream_int<uint8>, luaseq::to_lua_int<uint8> );
		map[ "int16" ] = std::make_pair( luaseq::to_stream_int<int16>, luaseq::to_lua_int<int16> );
		map[ "uint16" ] = std::make_pair( luaseq::to_stream_int<uint16>, luaseq::to_lua_int<uint16> );
		map[ "int32" ] = std::make_pair( luaseq::to_stream_int<int32>, luaseq::to_lua_int<int32> );
		map[ "uint32" ] = std::make_pair( luaseq::to_stream_int<uint32>, luaseq::to_lua_int<uint32> );

		map[ "float" ] = std::make_pair( luaseq::to_stream_f<float>, luaseq::to_lua_f<float> );
		map[ "double" ] = std::make_pair( luaseq::to_stream_f<double>, luaseq::to_lua_f<double> );

		map[ "string" ] = std::make_pair( luaseq::to_stream_string, luaseq::to_lua_string );
		map[ "bytes" ] = std::make_pair( luaseq::to_stream_bytes, luaseq::to_lua_bytes );

		map[ "array" ] = std::make_pair( luaseq::to_stream_array, luaseq::to_lua_array );
		map[ "indices" ] = std::make_pair( luaseq::to_stream_indices, luaseq::to_lua_indices );
		map[ "map" ] = std::make_pair( luaseq::to_stream_map, luaseq::to_lua_map );
	}
	return map;
}

void declare_base_reg_method( lua_State* L, int32 idx, std::vector< void* >& to_stream_method_list, std::vector< void* >& to_lua_method_list )
{
	const char* member_type = lua_tostring( L, idx );
	std::pair< luaseq::FToStream, luaseq::FToLua > method = luaseq_method()[ member_type ];
	if ( method.first != NULL && method.second != NULL )
	{
		to_stream_method_list.push_back( (void*)method.first );

		to_lua_method_list.push_back( (void*)method.second );
	}
	else
	{
		to_stream_method_list.push_back( (void*)luaseq::to_stream_object );
		to_stream_method_list.push_back( (void*)luaseq::to_stream );
		to_stream_method_list.push_back( strdup( member_type ) );

		to_lua_method_list.push_back( (void*)luaseq::to_lua_object );
		to_lua_method_list.push_back( (void*)luaseq::to_lua );
		to_lua_method_list.push_back( strdup( member_type ) );
	}
}

int32 declare_base_reg( lua_State* L )
{
	int32 n = lua_gettop(L);
	if ( n < 3 )
	{
		printf( "declare_base_reg param count[%d] error!\n", n );
		return 0;
	}

	const char* struct_name = lua_tostring( L, 1 );
	luaseq::T_DECLARE& declare = luaseq::declare_map()[ struct_name ];
	if ( lua_type( L, 2 ) == LUA_TSTRING )
		declare.first = lua_tostring( L, 2 );

	if ( n >= 4 )
	{
		name_handles()[ struct_name ] = lua_tointeger( L, 4 );
		cmd_handles()[ lua_tointeger( L, 4 ) ] = struct_name;
	}

	lua_pushnil( L );
	{
		while( lua_next( L, 3 ) != 0 )
		{
			int32 top1 = lua_gettop( L );

			lua_pushnil( L );
			{
				std::string member_name;
				std::vector< void* > to_stream_method_list, to_lua_method_list;

				for( int32 i = 0; lua_next( L, top1 ) != 0; ++i )
				{
					if ( i == 0 )
					{
						member_name = lua_tostring( L, -1 );
						lua_pop( L, 1 );
						continue;
					}

					switch ( lua_type( L, -1 ) )
					{
					case LUA_TSTRING:
						{
							declare_base_reg_method( L, -1, to_stream_method_list, to_lua_method_list );
						}
						break;
					case LUA_TTABLE:
						{
							int32 top2 = lua_gettop( L );

							lua_pushnil( L );
							{
								while ( lua_next( L, top2 ) != 0 )
								{
									declare_base_reg_method( L, -1, to_stream_method_list, to_lua_method_list );

									lua_pop( L, 1 );
								}
							}
						}
						break;
					}

					lua_pop( L, 1 );
				}

				declare.second.push_back( std::make_pair( member_name, std::make_pair( to_stream_method_list, to_lua_method_list ) ) );
			}

			lua_pop( L, 1 );
		}
	}

	return 0;
}

int32 declare_base_rand( lua_State* L )
{
	int32 n = lua_gettop(L);
	if ( n < 3 )
	{
		printf( "declare_base_rand param count[%d] error!\n", n );
		return 0;
	}

	//取得结构名
	int32 min = (int32)lua_tointeger( L, 1 );
	int32 max = (int32)lua_tointeger( L, 2 );

	//展开 SInteger.value
	lua_pushnil( L );
	lua_next( L, 3 );

	//获取 SInteger.value 值
	int32 seed = (int32)lua_tointeger( L, -1 );

	//随机运算
	int32 result = TRand( min, max, (uint32*)&seed );

	//弹出 SInteger.value 值
	lua_pop( L, 1 );

	//重新压入 Sinteger.value 新值
	lua_pushinteger( L, seed );

	//回设到 SInteger table
	lua_settable( L, 3 );

	//压入返回值
	lua_pushinteger( L, result );

	return 1;
}

} // namespace declare

