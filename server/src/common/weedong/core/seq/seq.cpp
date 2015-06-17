#include <weedong/core/seq/seq.h>

#include <list>
#include <sstream>

namespace wd
{
//CSeq
CSeq::CSeq()
{
}

CSeq::~CSeq()
{
}

CSeq* CSeq::clone(void)
{
    return ( new CSeq(*this) );
}

bool CSeq::write( wd::CStream &stream )
{
    uint32 uiSize = 0;
    return loop( stream, CSeq::eWrite, uiSize )
        && loopend( stream, CSeq::eWrite, uiSize );
}

bool CSeq::read( wd::CStream &stream )
{
    uint32 uiSize = 0;
    return loop( stream, CSeq::eRead, uiSize );
}

/*************************************************
  Description:      // 序列化变量循环处理模式
  Param:            // stream : 处理用二进制流
                    // eType : 处理方式
*************************************************/
bool CSeq::loop( wd::CStream &stream, CSeq::ELoopType eType, uint32& uiSize )
{
    switch ( eType )
    {
    case CSeq::eRead:
        stream >> uiSize;
        break;
    case CSeq::eWrite:
        stream << uiSize;
        break;
    case CSeq::eUnknow:
        assert(false);
    }
    return true;
}

bool CSeq::loopend( wd::CStream &stream, CSeq::ELoopType eType, uint32& uiSize )
{
    uint32 now_position = 0;
    uint32 old_position = 0;
    switch ( eType )
    {
    case CSeq::eRead:
        if ( uiSize > 0 )
            stream.position( stream.position() + uiSize );
        break;
    case CSeq::eWrite:
        now_position = stream.position();
        if ( uiSize > now_position + sizeof(uiSize) )
            return false;
        old_position = now_position - uiSize - sizeof(uiSize);
        *((uint32*)(&stream[old_position])) = uiSize;
        uiSize += sizeof( uiSize );
        break;
    case CSeq::eUnknow:
        assert(false);
    }
    return true;
}

/*************************************************
  Description:      // 序列化元素逻辑处理模型
  Param:            // value : 元素值
                    // type : 处理工作模式
                    // stream : 二进制数据处理流
                    // pszVarName : 变量名称
                    // pszVarDescript : 变量描述
                    // pszVarType : 变量类型名
*************************************************/
bool CSeq::TFVarTypeProcess(int8& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(uint8& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(int16& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }
    
    return true;
}
bool CSeq::TFVarTypeProcess(uint16& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(int32& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(uint32& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof(value);
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(float& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        uiSize += sizeof( value );
        stream << value;
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(double& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    switch ( type )
    {
    case CSeq::eRead:
        if ( 0 == uiSize )
            return true;
        if ( stream.available() < sizeof( value ) )
            return false;
        if ( uiSize < sizeof( value ) )
            return false;
        uiSize -= sizeof( value );
        stream >> value;
        break;
    case CSeq::eWrite:
        stream << value;
        uiSize += sizeof( value );
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(std::string& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    uint16 uiLength = 0;
    switch ( type )
    {
    case CSeq::eRead:
        {
            if ( 0 == uiSize )
                return true;
            if ( stream.available() < sizeof( uiLength ) )
                return false;
            if ( uiSize < sizeof( uiLength ) )
                return false;
            uiSize -= sizeof( uiLength );

            stream >> uiLength;
            if ( stream.available() < uiLength )
                return false;
            if ( uiSize < uiLength )
                return false;
            uiSize -= uiLength;

            if ( uiLength <= 0 )
                value.clear();
            else
            {
                value.resize( uiLength );
                stream.read( (int8*)&value[0], uiLength );
            }
        }
        break;
    case CSeq::eWrite:
        {
            uiLength = (uint16)value.length();
            uiSize += sizeof( uiLength );
            stream << uiLength;
            if ( uiLength > 0 )
            {
                stream.write( value.c_str(), uiLength );
                uiSize += uiLength;
            }
        }
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}
bool CSeq::TFVarTypeProcess(wd::CStream& value, CSeq::ELoopType type,wd::CStream &stream, uint32& uiSize)
{
    uint32 uiLength = 0;
    switch ( type )
    {
    case CSeq::eRead:
        {
            value.clear();

            if ( 0 == uiSize )
                return true;

            if ( stream.available() < sizeof( uiLength ) )
                return false;
            if ( uiSize < sizeof( uiLength ) )
                return false;
            uiSize -= sizeof( uiLength );

            stream >> uiLength;
            if ( stream.available() < uiLength )
                return false;
            if ( uiSize < uiLength )
                return false;
            uiSize -= uiLength;

            value.write( &stream[ stream.position() ], uiLength );
            stream.position( stream.position() + uiLength );
        }
        break;
    case CSeq::eWrite:
        {
            uiLength = value.length();
            uiSize += sizeof( uiLength );

            stream << uiLength;
            stream.write( &value[0], uiLength );
            uiSize += uiLength;
        }
        break;
    case CSeq::eUnknow:
        assert(false);
    }

    return true;
}

}


