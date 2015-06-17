#include "luaseq.h"
#include "util.h"

namespace luaseq
{

//=========================================================================
std::map< std::string, luaseq::T_DECLARE >& declare_map(void)
{
	static std::map< std::string, luaseq::T_DECLARE > map;
	return map;
}

std::map< std::string, int32 > push_table_element( lua_State* L, int32 idx )
{
	std::map< std::string, int32 > map;

	int32 top = lua_gettop( L );

	lua_pushnil( L );
	while( lua_next( L, idx ) != 0 )
	{
        int32 size = map.size();

		map[ lua_tostring( L, -2 ) ] = top + size * 2 + 2;
		lua_pushvalue( L, -2 );
	}

	return map;
}

void pop_table_element( lua_State* L, int32 count )
{
	lua_pop( L, count * 2 );
}

//=========================================================================
void to_stream( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	T_DECLARE& declare = declare_map()[ *(char**)ptr_list ];

	//处理父结构
	if ( !declare.first.empty() )
	{
		std::map< std::string, luaseq::T_DECLARE >::iterator iter = declare_map().find( declare.first );
		assert( iter != declare_map().end() );

		char* parent_name = (char*)declare.first.c_str();
		to_stream( L, stream, NULL, element_indices, &parent_name );
	}

	int32 posi = stream.position();
	stream << posi;

	//处理结构成员
	for ( std::vector< T_MEMBER >::iterator iter = declare.second.begin();
		iter != declare.second.end();
		++iter )
	{
		int32* idx = NULL;

		if ( element_indices != NULL )
		{
			std::map< std::string, int32 >::iterator i = element_indices->find( iter->first );
			if ( i != element_indices->end() )
				idx = &(i->second);
		}

		//iter->second.first 为 to_stream
		//iter->second.second 为 to_lua
		FToStream* method_array = (FToStream*)&iter->second.first[0];
		(*method_array)( L, stream, idx, NULL, method_array + 1 );
	}

	*(uint32*)&stream[ posi ] = stream.length() - posi - 4;
}

void to_stream_string( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	std::string value;

	if ( idx != NULL )
		value = lua_tostring( L, *idx );

	uint16 length = value.size();
	stream << length;

	if ( length > 0 )
		stream << value;
}
void to_stream_bytes( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	char* pointer = NULL;

	if ( idx != NULL )
		pointer = (char*)lua_touserdata( L, *idx );

	uint32 length = 0;
	if ( pointer != NULL )
	{
		if ( *(uint32*)pointer != 0 )
		{
			length = *(uint32*)pointer;
		}
	}

	stream << length;
	if ( length > 0 )
		stream.write( pointer + 4, length );
}

void to_stream_object( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	FToStream* method_array = (FToStream*)ptr_list;
	if ( idx != NULL )
	{
		//压入所有参数
		std::map< std::string, int32 > element_map = luaseq::push_table_element( L, *idx );

		(*method_array)( L, stream, NULL, &element_map, method_array + 1 );

		//弹出所有参数
		luaseq::pop_table_element( L, element_map.size() );

		return;
	}

	//插入空对象
	(*method_array)( L, stream, NULL, NULL, method_array + 1 );
}

void to_stream_array( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	FToStream* method_array = (FToStream*)ptr_list;

	uint16 length = 0;

	if ( idx != NULL )
	{
		int32 top = lua_gettop( L );
		uint16 length = 0;
		std::map< int32, wd::CStream > array_stream;

		//遍历数组
		lua_pushnil( L );
		while( lua_next( L, *idx ) != 0 )
		{
			int32 key = lua_tointeger( L, -2 );
			if ( key <= 0 )
			{
				lua_pop( L, 1 );
				continue;
			}
			if ( key > length )
				length = (uint16)( key );

			int32 index = top + 2;
			(*method_array)( L, array_stream[ key ], &index, NULL, method_array + 1 );

			lua_pop( L, 1 );
		}

		//输出数组长度
		stream << length;

		//拼组数据
		int32 index = 1;
		for ( std::map< int32, wd::CStream >::iterator iter = array_stream.begin();
			iter != array_stream.end();
			++iter, ++index )
		{
			for ( ; index < iter->first; ++index )
				(*method_array)( L, stream, NULL, NULL, method_array + 1 );

			stream << iter->second;
		}

		return;
	}

	stream << length;
}

void to_stream_indices( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	FToStream* method_array = (FToStream*)ptr_list;
	uint16 length = 0;

	if ( idx != NULL )
	{
		int32 posi = stream.position();
		int32 top = lua_gettop( L );

		//预先压入长度
		uint16 length = 0;
		stream << length;

		//遍历数组
		lua_pushnil( L );
		for( ; lua_next( L, *idx ) != 0; ++length )
		{
			uint32 key = (uint32)lua_tonumber( L, -2 );
			int32 index = top + 2;

			stream << key;
			(*method_array)( L, stream, &index, NULL, method_array + 1 );

			lua_pop( L, 1 );
		}

		//修改长度数据
		*(uint16*)&stream[ posi ] = length;

		return;
	}

	stream << length;
}

void to_stream_map( lua_State* L, wd::CStream& stream, int32* idx, std::map< std::string, int32 >* element_indices, void* ptr_list )
{
	FToStream* method_array = (FToStream*)ptr_list;
	uint16 length = 0;

	if ( idx != NULL )
	{
		int32 posi = stream.position();
		int32 top = lua_gettop( L );

		//预先压入长度
		uint16 length = 0;
		stream << length;

		//遍历数组
		lua_pushnil( L );
		for( ; lua_next( L, *idx ) != 0; ++length )
		{
			std::string key = lua_tostring( L, -2 );
			uint16 key_length = key.size();
			int32 index = top + 2;

			stream << key_length;
			stream << key;
			(*method_array)( L, stream, &index, NULL, method_array + 1 );

			lua_pop( L, 1 );
		}

		//修改长度数据
		*(uint16*)&stream[ posi ] = length;

		return;
	}

	stream << length;
}

//=========================================================================
void to_lua( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	T_DECLARE& declare = declare_map()[ *(char**)ptr_list ];

	if ( !declare.first.empty() )
	{
		char* parent_name = (char*)declare.first.c_str();
		to_lua( L, stream, size, &parent_name );
	}

	//获取对象数据大小
	uint32 object_size = 0;
	if ( size >= 4 )
	{
		stream >> object_size;
		size -= 4;
	}
	else
		size = 0;

	//容错数据大小处理
	if ( size < object_size  )
		object_size = size;
	size -= object_size;

	//设置结构数据转换后的指针位置
	int32 next_posi = stream.position() + object_size;

	for ( std::vector< T_MEMBER >::iterator iter = declare.second.begin();
		iter != declare.second.end();
		++iter )
	{
		//iter->second.first 为 to_stream
		//iter->second.second 为 to_lua
		const char* name = iter->first.c_str();
		ptr_list = &iter->second.second[0];

		to_lua_key( L, name, stream, object_size, ptr_list );
	}

	//重置数据流指针
	stream.position( next_posi );
}
void to_lua_key( lua_State* L, const char* name, wd::CStream& stream, uint32& size, void* ptr_list )
{
	lua_pushstring( L, name );

	FToLua* method_array = (FToLua*)ptr_list;
	(*method_array)( L, stream, size, method_array + 1 );

	lua_settable( L, -3 );
}
void to_lua_key( lua_State* L, uint32 index, wd::CStream& stream, uint32& size, void* ptr_list )
{
	lua_pushinteger( L, index );

	FToLua* method_array = (FToLua*)ptr_list;
	(*method_array)( L, stream, size, method_array + 1 );

	lua_settable( L, -3 );
}
void to_lua_string( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	std::string string;
	uint16 length = 0;

	if ( size >= sizeof( length ) )
	{
		stream >> length;

		size -= sizeof( length );
		if ( size > 0 && size >= length )
		{
			stream.read( string, length );
			size -= length;
		}
		else
			size = 0;
	}
	else
		size = 0;

	lua_pushlstring( L, string.c_str(), string.size() );
}
void to_lua_bytes( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	uint32 length = 0;

	if ( size >= sizeof( length ) )
	{
		stream >> length;

		size -= sizeof( length );
		if ( size > 0 && size >= length )
		{
			//创建二进制数据对象
			char* pointer = (char*)lua_newuserdata( L, sizeof( length ) + length );

			//填充数据
			*(uint32*)pointer = length;
			stream.read( pointer + 4, length );

			size -= length;

			return;
		}
		else
			size = 0;
	}
	else
		size = 0;

	uint32* pointer = (uint32*)lua_newuserdata( L, sizeof( length ) );
	*pointer = 0;
}
void to_lua_object( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	lua_newtable( L );

	FToLua* method_array = (FToLua*)ptr_list;
	(*method_array)( L, stream, size, method_array + 1 );
}
void to_lua_array( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	lua_newtable( L );

	//容错处理
	if ( size >= 2 )
	{
		uint16 length = 0;
		stream >> length;
		size -= 2;

		//取出元素长度
		if ( length > 0 )
		{
			for ( uint16 i = 1; i <= length; ++i )
				to_lua_key( L, (uint32)i, stream, size, ptr_list );
		}
	}
}
void to_lua_indices( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	lua_newtable( L );

	//容错处理
	if ( size >= 2 )
	{
		uint16 length = 0;
		stream >> length;
		size -= 2;

		//取出元素长度
		if ( length > 0 )
		{
			for ( uint16 i = 0; i < length; ++i )
			{
				//取出索引
				uint32 index = 0;

				if ( size < 4 )
				{
					size = 0;
					break;
				}

				stream >> index;
				size -= 4;

				to_lua_key( L, (uint32)index, stream, size, ptr_list );
			}
		}
	}
}
void to_lua_map( lua_State* L, wd::CStream& stream, uint32& size, void* ptr_list )
{
	lua_newtable( L );

	//容错处理
	if ( size >= 2 )
	{
		uint16 length = 0;
		stream >> length;
		size -= 2;

		//取出元素长度
		if ( length > 0 )
		{
			for ( uint16 i = 0; i < length; ++i )
			{
				//容错处理
				if ( size < 2 )
				{
					size = 0;
					break;
				}

				//取出键长度
				uint16 key_size = 0;
				stream >> key_size;
				size -= 2;

				//容错处理
				if ( size < key_size )
				{
					size = 0;
					break;
				}

				//取出键值
				std::string key;
				stream.read( key, key_size );
				size -= key_size;

				to_lua_key( L, key.c_str(), stream, size, ptr_list );
			}
		}
	}
}

//=================call====================
TCall::TCall( lua_State* L, std::string method )
{
    root = L;
    name = method;
    param_count = 0;

    path = Split( name, "." );

    if ( root == NULL )
        return;

    int32 index = LUA_GLOBALSINDEX;
    for ( int32 i = 0; i < (int32)path.size() - 1; ++i )
    {
        lua_getfield( root, index, path[i].c_str() );
        if ( LUA_TTABLE != lua_type( root, -1 ) )
        {
            lua_pop( root, i + 1 );

            root = NULL;
            break;
        }

        index = -1;
    }

    if ( root != NULL )
    {
        lua_getfield( root, index, path[ path.size() - 1 ].c_str() );
        if ( LUA_TFUNCTION != lua_type( root, -1 ) )
        {
            lua_pop( root, path.size() );
            root = NULL;
        }
    }
}
TCall::~TCall()
{
}

TCall call( lua_State* L, std::string method )
{
    return TCall( L, method );
}

TReg<RegDefaultMethodType> reg( lua_State* L, std::string method )
{
    return TReg<RegDefaultMethodType>( L, method );
}

}


