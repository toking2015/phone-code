/*************************************************
  Model:            // 序列化结构
  Class:            // 研发三部
  Name:             // 黄少卿
  Date:             // 2011-11-21
  Descript:
    使用 <模板> 方式实现的序列化类功能

  支持的基本类型有如下:
  int8 uint8 int16 uint16 int32 uint32 float

  支持的对象类型如下:
  string : 通过 std::string 作为 string 类型的实现方式
  object : 只支持作为 CSeq 的派生类

  支持的容器类型有如下:
  array : 通过 std::vector 作为 array 类型的实现方式
  map : 通过 std::map 作为 map 类型的实现方式, key 统一为 std::string

  容器的元素类型接受范为是: [ 所有基本类型, 所有对象类型 ]
*************************************************/

#ifndef _WEEDONG_CORE_SEQ_SEQ_H_
#define _WEEDONG_CORE_SEQ_SEQ_H_

#include <vector>
#include <string>
#include <map>

#include <sstream>
#include <algorithm>
#include <assert.h>

#include <weedong/core/bstream/bstream.h>

namespace wd
{

/*************************************************
  Description:    // 序列化数据基类
  Other:          // 所有的序列化结构必须继承本基类
*************************************************/
class CSeq
{
public:
    /*************************************************
      Description:    // 序列化变量处理模式
    *************************************************/
    enum ELoopType
    {
        eUnknow = 0,    //不处理
        eRead = 1,      //从数据流中读取数据
        eWrite = 2,     //将数据注到数据流中
    };

    /*************************************************
      Description:      // 序列化基类构造函数
    *************************************************/
    CSeq();

    /*************************************************
      Description:      // 序列化基类虚析构函数, 允许被继承
    *************************************************/
    virtual ~CSeq();

    virtual CSeq* clone(void);
    virtual bool write( wd::CStream &stream );
    virtual bool read( wd::CStream &stream );
    /*************************************************
      Description:      // 序列化变量循环处理模式
      Param:            // stream : 处理用二进制流
                        // eType : 处理方式
    *************************************************/
    bool loop( wd::CStream &stream, CSeq::ELoopType eType, uint32& uiSize );
    virtual bool loopend( wd::CStream &stream, CSeq::ELoopType eType, uint32& uiSize );
    
    /*************************************************
      Description:      // 序列化元素逻辑处理模型
      Param:            // value : 元素值
                        // type : 处理工作模式
                        // stream : 二进制数据处理流
                        // pszVarName : 变量名称
                        // pszVarDescript : 变量描述
                        // pszVarType : 变量类型名
    *************************************************/
    template<typename T> static bool TFVarTypeProcess(T& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize)
    {
        uint32 _uiSize = 0;
        uint32 _pos_i = 0;
        uint32 _pos_j = 0;
        bool b_loop = false;
        switch ( type )
        {
        case CSeq::eRead:
            if ( uiSize < sizeof(_uiSize) )
                return false;
            _pos_i = stream.position();
            b_loop = value.loop( stream, type, _uiSize );
            _pos_j = stream.position();
            if ( uiSize > _pos_j - _pos_i)
                uiSize -= _pos_j - _pos_i;
            else
                uiSize = 0;
            return b_loop;
        case CSeq::eWrite:
            _pos_i = stream.position();
            b_loop = value.loop( stream, type, _uiSize );
            _pos_j = stream.position();
            uiSize += _pos_j - _pos_i;
            return b_loop;
        default:
            assert(false);
        }
        return false;
    }
    /*************************************************
      Description:      // 同上
      Other:            // 对基本元素的函数重载实现
    *************************************************/
    static bool TFVarTypeProcess(int8& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(uint8& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(int16& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(uint16& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(int32& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(uint32& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(float& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(double& value, CSeq::ELoopType type, wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(std::string& value, CSeq::ELoopType type,wd::CStream &stream, uint32 &uiSize);
    static bool TFVarTypeProcess(wd::CStream& value, CSeq::ELoopType type,wd::CStream &stream, uint32 &uiSize);
    /*************************************************
      Description:      // 同上
      Other:            // 对 array 的函数模板实现
    *************************************************/
	struct vector_type_process
	{
		CSeq::ELoopType Type;
		wd::CStream &Stream;
        bool &result;
        uint32 &uiSize;
		vector_type_process( CSeq::ELoopType type, wd::CStream &stream, bool& r, uint32 &s ) : Type(type), Stream(stream), result(r), uiSize(s) {}

		template<typename T> void operator()( T &value )
		{
            if ( result )
			    result = TFVarTypeProcess( value, Type, Stream, uiSize );
		}
	};
    template<typename T> static bool TFVarTypeProcess(std::vector<T>& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
    {
        bool result = true;
        uint16 uiLength = 0;
        switch ( type )
        {
        case CSeq::eRead:
            {
                stream >> uiLength;
                if ( uiSize < sizeof( uiLength ) )
                    return false;
                uiSize -= sizeof( uiLength );

                value.clear();
                if ( uiLength > 0 )
                {
                    value.resize( uiLength );

                    vector_type_process process( type, stream, result, uiSize );
					std::for_each( value.begin(), value.end(), process );
                }
            }
            break;
        case CSeq::eWrite:
            {
                uiLength = (uint16)value.size();
                stream << uiLength;
                uiSize += sizeof( uiLength );

                if ( uiLength > 0 )
                {
                    vector_type_process process( type, stream, result, uiSize );
					std::for_each( value.begin(), value.end(), process );
                }
            }
            break;
        default:
            assert(false);
        }

        return result;
    }
    /*************************************************
      Description:      // 同上
      Other:            // 对 map 的函数模板实现
    *************************************************/
	struct map_type_process
	{
		CSeq::ELoopType Type;
		wd::CStream &Stream;
        bool &result;
        uint32 &uiSize;

		map_type_process( CSeq::ELoopType type, wd::CStream &stream, bool& r, uint32 &s ) : Type(type), Stream(stream), result(r), uiSize(s){}

		template<typename T> void operator()( T& value )
		{
            if ( result )
            {
			    uint16 uiStrLength = (uint16)value.first.length();
                Stream << uiStrLength;
			    Stream << value.first;
                uiSize += sizeof( uiStrLength ) + uiStrLength;

                result = TFVarTypeProcess( value.second, Type, Stream, uiSize );
            }
		}
	};
    template<typename T> static bool TFVarTypeProcess(std::map<std::string, T>& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
    {
        bool result = true;

        std::string strKey;
        uint16 uiMapLength = 0;
        uint16 uiStrLength = 0;

        switch ( type )
        {
        case CSeq::eRead:
            {
                stream >> uiMapLength;
                if ( uiSize < sizeof( uiMapLength ) )
                    return false;
                uiSize -= sizeof( uiMapLength );

                value.clear();
                for ( int i=0; i<uiMapLength; ++i )
                {
                    stream >> uiStrLength;
                    stream.read( strKey, uiStrLength );
                    if ( uiSize < sizeof(uiStrLength) + uiStrLength )
                        return false;
                    uiSize -= sizeof(uiStrLength) + uiStrLength;
                    if ( !TFVarTypeProcess( value[ strKey.c_str() ], type, stream, uiSize ) )
                        return false;
                }
            }
            break;
        case CSeq::eWrite:
            {
                uiMapLength = (uint16)value.size();
                stream << uiMapLength;
                uiSize += sizeof(uiMapLength);

                if ( uiMapLength > 0 )
                {
                    map_type_process process( type, stream, result, uiSize );
					std::for_each( value.begin(), value.end(), process );
                }
            }
            break;
        default:
            assert(false);
        }
        return result;
    }
    /*************************************************
      Description:      // 同上
      Other:            // 对 indices 的函数模板实现
    *************************************************/
	struct indices_type_process
	{
		CSeq::ELoopType Type;
		wd::CStream &Stream;
        bool &result;
        uint32 &uiSize;

	    indices_type_process( CSeq::ELoopType type, wd::CStream &stream, bool& r, uint32& s ) : Type(type), Stream(stream), result(r), uiSize(s){}

		template<typename T> void operator()( T &value )
		{
            if ( result )
            {
			    Stream << value.first;
                uiSize += sizeof( value.first );

                result = TFVarTypeProcess( value.second, Type, Stream, uiSize );
            }
		}
	};
    template<typename T> static bool TFVarTypeProcess(std::map<uint32, T>& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize )
    {
        bool result = true;

        uint16 uiIndicesLength = 0;
        uint32 uiIndicesKey = 0;

        switch ( type )
        {
        case CSeq::eRead:
            {
                stream >> uiIndicesLength;
                if ( uiSize < sizeof( uiIndicesLength ) )
                    return false;
                uiSize -= sizeof( uiIndicesLength );

                value.clear();
                for ( int i=0; i<uiIndicesLength; ++i )
                {
                    stream >> uiIndicesKey;
                    if ( uiSize < sizeof( uiIndicesKey ) )
                        return false;
                        uiSize -= sizeof( uiIndicesKey );
                    if ( !TFVarTypeProcess( value[ uiIndicesKey ], type, stream, uiSize ) )
                        return false;
                }
            }
            break;
        case CSeq::eWrite:
            {
                uiIndicesLength = (uint16)value.size();
                stream << uiIndicesLength;
                uiSize += sizeof( uiIndicesLength );

                if ( uiIndicesLength > 0 )
                {
                    indices_type_process process( type, stream, result, uiSize );
                    std::for_each( value.begin(), value.end(), process );
                }
            }
            break;
        default:
            assert(false);
        }
        return result;
    }
    /*************************************************
      Description:      // 同上
      Other:            // 对 indices 的函数模板实现
    *************************************************/
	struct indices_type_process_p
	{
		CSeq::ELoopType Type;
		wd::CStream &Stream;
        bool &result;
        uint32 &uiSize;

	    indices_type_process_p( CSeq::ELoopType type, wd::CStream &stream, bool& r, uint32& s ) : Type(type), Stream(stream), result(r), uiSize(s){}

		template<typename T> void operator()( T &value )
		{
            if ( result )
            {
			    Stream << value.first;
                uiSize += sizeof( value.first );

                result = TFVarTypeProcess( *(value.second), Type, Stream, uiSize );
            }
		}
	};
    template<typename T> static bool TFVarTypeProcess(std::map<uint32, T*>& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize )
    {
        bool result = true;

        uint16 uiIndicesLength = 0;
        uint32 uiIndicesKey = 0;

        switch ( type )
        {
        case CSeq::eRead:
            {
                stream >> uiIndicesLength;
                if ( uiSize < sizeof( uiIndicesLength ) )
                    return false;
                uiSize -= sizeof( uiIndicesLength );

                value.clear();
                for ( int i=0; i<uiIndicesLength; ++i )
                {
                    stream >> uiIndicesKey;
                    if ( uiSize < sizeof( uiIndicesKey ) )
                        return false;
                        uiSize -= sizeof( uiIndicesKey );
                    T *pt = new T();
                    value[ uiIndicesKey ] = pt;
                    if ( !TFVarTypeProcess( *pt, type, stream, uiSize ) )
                        return false;
                }
            }
            break;
        case CSeq::eWrite:
            {
                uiIndicesLength = (uint16)value.size();
                stream << uiIndicesLength;
                uiSize += sizeof( uiIndicesLength );

                if ( uiIndicesLength > 0 )
                {
                    indices_type_process_p process( type, stream, result, uiSize );
                    std::for_each( value.begin(), value.end(), process );
                }
            }
            break;
        default:
            assert(false);
        }
        return result;
    }
};

}

#endif

