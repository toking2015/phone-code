#include "jsonconfig.h"
#include <fstream>
#include "log.h"

bool CJson::read( std::string& json_string )
{
    return m_reader.parse( json_string, m_value );
}

bool CJson::read(const char* name, int json_type)
{
    if (is_null(name))
        return false;
    if (kString == json_type)
    {
        return m_reader.parse(name, m_value);
    }
    if (kFile == json_type)
    {
        std::ifstream ifs(name);
        return ifs.good() && m_reader.parse(ifs, m_value);
    }

    return false;
}

std::string CJson::write(int json_type)
{
    if (kFast == json_type)
    {
        Json::FastWriter writer;
        return writer.write(m_value);
    }
    if (kStyled == json_type)
    {
        Json::StyledWriter writer;
        return writer.write(m_value);
    }
    return "";
}

Json::Value& CJson::value(void)
{
    return m_value;
}

bool CJson::is_null(const char* s)
{
    return NULL == s || '\0' == s[0];
}

/***************以下函数用于读取json静态数据***************/
unsigned int to_uint(const Json::Value& val)
{
    if ( val.isIntegral() )
        return val.asUInt();

    if ( val.isDouble() )
        return (unsigned int)val.asDouble();

    if ( val.isString() )
        return strtoul(val.asCString(), NULL, 0 );

    return 0;
}

const char* to_str(const Json::Value& val)
{
    if ( val.isString() )
        return val.asCString();

    static const char* empty = "";
    return empty;
}

std::string CJson::dir;
CJson CJson::Load( std::string name )
{
    CJson cj;

    if ( !cj.read( ( dir + name + ".json" ).c_str(), CJson::kFile ) )
        THROW( "load json %s error!", name.c_str() );

    return cj;
}

CJson CJson::LoadString( std::string& json_string )
{
    CJson cj;

    cj.read( json_string );

    return cj;
}

std::string CJson::Write( Json::Value& json )
{
    return Json::FastWriter().write( json );
}

