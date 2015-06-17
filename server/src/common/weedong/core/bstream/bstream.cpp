#include <weedong/core/bstream/bstream.h>

namespace wd
{

/*************************************************
  Description:    // 构造函数
  Input:          // uiSize 数据缓存预分配大小
*************************************************/
CStream::CStream( uint32 uiSize/* = 1024 */)
{
    m_Buff.reserve( uiSize );
    m_Pointer = m_Buff.end();
}

CStream::CStream( const void *pvData, uint32 uiSize )
{
    m_Buff.resize( uiSize );
    m_Pointer = m_Buff.begin();

    write( pvData, uiSize );
}

CStream::CStream( wd::CStream const& stream )
{
    m_Buff = stream.m_Buff;
    m_Stack = stream.m_Stack;

    position( ((wd::CStream&)stream).position() );
}

/*************************************************
  Description:    // 析构函数, 允许类被继续
*************************************************/
CStream::~CStream()
{
}

/*************************************************
  Description:    // 获取数据流当前可用字节数
  Return:         // 返回可用字节数
*************************************************/
uint32 CStream::available(void)
{
    return (uint32)( m_Buff.end() - m_Pointer );
}

/*************************************************
  Description:    // 获取数据流数据总长度
  Return:         // 返回数据流总长度
*************************************************/
uint32 CStream::length(void)
{
    return (uint32)( m_Buff.size() );
}

/*************************************************
  Description:    // 清除数据流
*************************************************/
void CStream::clear(void)
{
    m_Buff.clear();
    m_Pointer = m_Buff.end();

    m_Stack.clear();
}

/*************************************************
  Description:    // 重置缓冲区尺寸
*************************************************/
void CStream::resize( uint32 size )
{
    m_Buff.resize( size );
    m_Pointer = m_Buff.end();

    m_Stack.clear();
}

/*************************************************
  Description:    // 获取数据流当前指针位置
  Return:         // 返回数据流指针位置索引
  Oter:           // 从 0 开始
*************************************************/
uint32 CStream::position(void)
{
    return (uint32)( m_Pointer - m_Buff.begin() );
}

/*************************************************
  Description:    // 设置数据流指针位置
  Oter:           // 从 0 开始
*************************************************/
void CStream::position( uint32 uiPosition )
{
    if ( uiPosition > m_Buff.size() )
    {
        //throw new exception( "指针设置超出数据流范围!" );
        return;
    }

    m_Pointer = m_Buff.begin() + uiPosition;
}

void CStream::posi_push(void)
{
    m_Stack.push_front( position() );
}

void CStream::posi_pop(void)
{
    position( *m_Stack.begin() );
    m_Stack.pop_front();
}

void CStream::posi_clear(void)
{
    m_Stack.clear();
}

wd::CStream& CStream::operator += ( int32 offset )
{
    position( position() + offset );
    return (*this);
}
wd::CStream& CStream::operator -= ( int32 offset )
{
    position( position() - offset );
    return (*this);
}

/*************************************************
  Description:    // 缩减数据
  Oter:           // 缩减从 0 开始到当前 position 位置的数据
*************************************************/
void CStream::erase(void)
{
    m_Buff.erase( m_Buff.begin(), m_Pointer );
    m_Pointer = m_Buff.begin();

    m_Stack.clear();
}

/*************************************************
  Description:    // 获取数据流下标引用位置
  Input:          // position : 数据流指针位置
  Return:         // 数据流数据单元引用
*************************************************/
uint8& CStream::operator [] ( int32 position )
{
    return *( m_Buff.begin() + position );
}

/*************************************************
  Description:    // 从当前数据指针位置读取数据流中的数据
  Input:          // pvData : 数据缓冲
                  // uiSize : 读取长度
*************************************************/
void CStream::read( void *pvData, uint32 uiSize )
{
    if ( available() < uiSize )
    {
        //throw new exception( "没有足够的可读数据流!" );
        return;
    }

    memcpy( pvData, &(*m_Pointer), uiSize );
    m_Pointer += uiSize;
}

/*************************************************
  Description:    // 从当产数据指针位置写入数据
  Input:          // pvData : 需要写入的二进制指针变量
  Return:         // uiSize : 需要写入的数据长度
*************************************************/
void CStream::write( const void *pvData, uint32 uiSize )
{
    uint32 posi = position();

    if ( m_Buff.size() != posi + uiSize )
        m_Buff.resize( posi + uiSize );
    memcpy( &m_Buff[ posi ], pvData, uiSize );

    m_Pointer = m_Buff.end();
}

/*************************************************
  Description:    // 从当前指针位置读取字符串
  Input:          // strValue : 读取的数据将保存到该 std::string 变量中
                  // uiSize : 需要读取的数据长度
*************************************************/
void CStream::read( std::string &strValue, uint32 uiSize )
{
    strValue.resize( uiSize );

    read( &strValue[0], uiSize );
}

/*************************************************
  Description:    // 在当前指针位置中写入数据
  Input:          // strValue : 需要写入的 std::string 字符串变量
                  // uiSize : 需要写入的数据长度
*************************************************/
void CStream::write( std::string &strValue, uint32 uiSize )
{
    write( &strValue[0], uiSize );
}

//=================================外部函数==================================
/*************************************************
Description:    // 以下是对象数据流
 *************************************************/
template<> CStream& operator >> ( CStream& stream, std::vector<uint8> &vecBuff )
{
    vecBuff.insert( vecBuff.end(), &stream[0], &stream[0] + stream.length() );
    stream.position( stream.length() );

    return stream;
}
template<> CStream& operator << ( CStream& stream, std::vector<uint8> &vecBuff )
{
    stream.write( &vecBuff[0], (uint32)vecBuff.size() );
    return stream;
}
template<> CStream& operator << ( CStream& l, CStream& r )
{
    std::vector<uint8> bytes;
    r >> bytes;

    return ( l << bytes );
}
template<> CStream& operator << ( CStream& stream, const std::string& v )
{
    stream.write( &v[0], v.size() );
    return stream;
}
template<> CStream& operator << ( CStream& stream, std::string& v )
{
    stream.write( &v[0], v.size() );
    return stream;
}

/*************************************************
Description:    // 以下是基本数据流
 *************************************************/
#define BSTREAM_OPERATOR(T)\
template<> CStream& operator << ( CStream& stream, const T &v )\
{\
    stream.write( &v, sizeof( v ) );\
    return stream;\
}\
template<> CStream& operator << ( CStream& stream, T &v )\
{\
    stream.write( &v, sizeof( v ) );\
    return stream;\
}\
template<> CStream& operator >> ( CStream& stream, T &v )\
{\
    stream.read( &v, sizeof( v ) );\
    return stream;\
}

BSTREAM_OPERATOR( bool );
BSTREAM_OPERATOR( int8 );
BSTREAM_OPERATOR( uint8 );
BSTREAM_OPERATOR( int16 );
BSTREAM_OPERATOR( uint16 );
BSTREAM_OPERATOR( int32 );
BSTREAM_OPERATOR( uint32 );
BSTREAM_OPERATOR( float );
BSTREAM_OPERATOR( double );

}
