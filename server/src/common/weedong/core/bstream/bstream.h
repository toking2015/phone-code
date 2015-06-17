/*************************************************
  Model:            // 二进制数据流
  Class:            // 研发三部
  Name:             // 黄少卿
  Date:             // 2011-10-25
  Descript:
    提供对二进制数据的流式基本操作
*************************************************/

#ifndef _WEEDONG_CORE_BSTREAM_BSTREAM_H_
#define _WEEDONG_CORE_BSTREAM_BSTREAM_H_

#include <weedong/core/os.h>
#include <algorithm>
#include <vector>
#include <string>
#include <deque>
#include <map>

namespace wd
{

/*************************************************
  Description:    二进制数据流处理类

  提供基本读写指针位置， 通过指针位置控制数据流的读写位置
*************************************************/
class CStream
{
private:
    std::vector<uint8> m_Buff;
    std::vector<uint8>::iterator m_Pointer;

    std::deque<int32> m_Stack;

public:
    /*************************************************
      Description:    // 构造函数
      Input:          // uiSize 数据缓存预分配大小
    *************************************************/
    CStream( uint32 uiSize = 1024 );
    CStream( const void *pvData, uint32 uiSize );
    CStream( wd::CStream const& stream );

    /*************************************************
      Description:    // 析构函数, 允许类被继续
    *************************************************/
    virtual ~CStream();

    /*************************************************
      Description:    // 获取数据流当前可用字节数
      Return:         // 返回可用字节数
    *************************************************/
    uint32 available(void);

    /*************************************************
      Description:    // 获取数据流数据总长度
      Return:         // 返回数据流总长度
    *************************************************/
    uint32 length(void);

    /*************************************************
      Description:    // 清除数据流
    *************************************************/
    void clear(void);

    /*************************************************
      Description:    // 重置缓冲区尺寸
    *************************************************/
    void resize( uint32 size );

    /*************************************************
      Description:    // 获取数据流当前指针位置
      Return:         // 返回数据流指针位置索引
      Oter:           // 从 0 开始
    *************************************************/
    uint32 position(void);

    /*************************************************
      Description:    // 设置数据流指针位置
      Oter:           // 从 0 开始
    *************************************************/
    void position( uint32 uiPosition );

    void posi_push(void);
    void posi_pop(void);
    void posi_clear(void);

    wd::CStream& operator += ( int32 offset );
    wd::CStream& operator -= ( int32 offset );

    /*************************************************
      Description:    // 缩减数据
      Oter:           // 缩减从 0 开始到当前 position 位置的数据
    *************************************************/
    void erase(void);

    /*************************************************
      Description:    // 获取数据流下标引用位置
      Input:          // position : 数据流指针位置
      Return:         // 数据流数据单元引用
    *************************************************/
    uint8& operator [] ( int32 position );

    /*************************************************
      Description:    // 从当前数据指针位置读取数据流中的数据
      Input:          // pvData : 数据缓冲
                      // uiSize : 读取长度
    *************************************************/
    void read( void *pvData, uint32 uiSize );

    /*************************************************
      Description:    // 从当产数据指针位置写入数据
      Input:          // pvData : 需要写入的二进制指针变量
      Return:         // uiSize : 需要写入的数据长度
    *************************************************/
    void write( const void *pvData, uint32 uiSize );

    /*************************************************
      Description:    // 从当前指针位置读取字符串
      Input:          // strValue : 读取的数据将保存到该 std::string 变量中
                      // uiSize : 需要读取的数据长度
    *************************************************/
    void read( std::string &strValue, uint32 uiSize );

    /*************************************************
      Description:    // 在当前指针位置中写入数据
      Input:          // strValue : 需要写入的 std::string 字符串变量
                      // uiSize : 需要写入的数据长度
    *************************************************/
    void write( std::string &strValue, uint32 uiSize );
};

/*************************************************
Description:    // 以下是序列化数据
 *************************************************/
template< typename T > CStream& operator << ( CStream& stream, T& seq )
{
    seq.write( stream );
    return stream;
}
template< typename T > CStream& operator >> ( CStream& stream, T& seq )
{
    seq.read( stream );
    return stream;
}

/*************************************************
Description:    // 以下是对象数据流
 *************************************************/
template<> CStream& operator >> ( CStream& stream, std::vector<uint8> &vecBuff );
template<> CStream& operator << ( CStream& stream, std::vector<uint8> &vecBuff );
template<> CStream& operator << ( CStream& l, CStream& r );
template<> CStream& operator << ( CStream& stream, const std::string& v );
template<> CStream& operator << ( CStream& stream, std::string& v );

/*************************************************
Description:    // 以下是基本数据流
 *************************************************/
template<> CStream& operator << ( CStream& stream, const bool &v );
template<> CStream& operator << ( CStream& stream, bool &v );
template<> CStream& operator >> ( CStream& stream, bool &v );

template<> CStream& operator << ( CStream& stream, const int8 &v );
template<> CStream& operator << ( CStream& stream, int8 &v );
template<> CStream& operator >> ( CStream& stream, int8 &v );

template<> CStream& operator << ( CStream& stream, const uint8 &v );
template<> CStream& operator << ( CStream& stream, uint8 &v );
template<> CStream& operator >> ( CStream& stream, uint8 &v );

template<> CStream& operator << ( CStream& stream, const int16 &v );
template<> CStream& operator << ( CStream& stream, int16 &v );
template<> CStream& operator >> ( CStream& stream, int16 &v );

template<> CStream& operator << ( CStream& stream, const uint16 &v );
template<> CStream& operator << ( CStream& stream, uint16 &v );
template<> CStream& operator >> ( CStream& stream, uint16 &v );

template<> CStream& operator << ( CStream& stream, const int32 &v );
template<> CStream& operator << ( CStream& stream, int32 &v );
template<> CStream& operator >> ( CStream& stream, int32 &v );

template<> CStream& operator << ( CStream& stream, const uint32 &v );
template<> CStream& operator << ( CStream& stream, uint32 &v );
template<> CStream& operator >> ( CStream& stream, uint32 &v );

template<> CStream& operator << ( CStream& stream, const float &v );
template<> CStream& operator << ( CStream& stream, float &v );
template<> CStream& operator >> ( CStream& stream, float &v );

template<> CStream& operator << ( CStream& stream, const double &v );
template<> CStream& operator << ( CStream& stream, double &v );
template<> CStream& operator >> ( CStream& stream, double &v );

/*************************************************
Description:    // 以下是容器数据流
 *************************************************/

//array
template< typename T >
struct stream_array_process
{
    wd::CStream& stream;
    stream_array_process( wd::CStream& s ) : stream(s){}

    void operator()( T& data )
    {
        stream << data;
    }
};
template< typename T > CStream& operator << ( CStream& stream, std::vector<T>& array )
{
    uint16 size = (uint16)array.size();
    stream << size;

    std::for_each( array.begin(), array.end(), stream_array_process<T>( stream ) );

    return stream;
}
template< typename T > CStream& operator >> ( CStream& stream, std::vector<T>& array )
{
    array.clear();

    uint16 size = 0;
    stream >> size;

    T data;
    for ( int32 i = 0; i < (int32)size; ++i )
    {
        stream >> data;
        array.push_back( data );
    }

    return stream;
}

//map
struct stream_map_process
{
    wd::CStream& stream;
    stream_map_process( wd::CStream& s ) : stream(s){}

    template< typename T >
    void operator()( T& data )
    {
        uint16 length = (uint16)data.first.size();

        stream << length;
        stream << data.first;
        stream << data.second;
    }
};
template< typename T > CStream& operator << ( CStream& stream, std::map< std::string, T >& map )
{
    uint16 size = (uint16)map.size();
    stream << size;

    std::for_each( map.begin(), map.end(), stream_map_process( stream ) );

    return stream;
}
template< typename T > CStream& operator >> ( CStream& stream, std::map< std::string, T >& map )
{
    map.clear();

    uint16 size = 0;
    stream >> size;

    std::string key;
    for ( int32 i = 0; i < (int32)size; ++i )
    {
        uint16 length = 0;
        stream >> length;

        key.resize( length );
        stream.read( &key[0], key.size() );

        stream >> map[ key ];
    }

    return stream;
}

//indices
struct stream_indices_process
{
    wd::CStream& stream;
    stream_indices_process( wd::CStream& s ) : stream(s){}

    template< typename T >
    void operator()( T& data )
    {
        stream << data.first;
        stream << data.second;
    }
};
template< typename T > CStream& operator << ( CStream& stream, std::map< uint32, T >& indices )
{
    uint16 size = (uint16)indices.size();
    stream << size;

    std::for_each( indices.begin(), indices.end(), stream_indices_process( stream ) );

    return stream;
}
template< typename T > CStream& operator >> ( CStream& stream, std::map< uint32, T >& indices )
{
    indices.clear();

    uint16 size = 0;
    stream >> size;

    uint32 key = 0;
    for ( int32 i = 0; i < (int32)size; ++i )
    {
        stream >> key;
        stream >> indices[ key ];
    }

    return stream;
}
}

#endif

