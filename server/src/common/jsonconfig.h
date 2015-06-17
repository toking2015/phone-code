#ifndef CONFIG_JSONCONFIG_H_
#define CONFIG_JSONCONFIG_H_

#include <json/json.h>

class CJson
{
public:
    enum
    {
        kFile = 0,      //文件
        kString = 1,    //字符流
    };
    enum
    {
        kFast = 0,      //协议传输
        kStyled = 1,    //格式化输出
    };

    bool read( std::string& json_string );
    bool read(const char* name, int json_type = kFile);

    std::string write(int json_type = kStyled);

    template <typename T > Json::Value& operator[] (T type)
    {
        return m_value[type];
    }

    Json::Value& value(void);

private:
    Json::Reader m_reader;
    Json::Value m_value;

    bool is_null(const char* s);

public:
    static std::string dir;
    static CJson Load( std::string name );
    static CJson LoadString( std::string& json_string );

    static std::string Write( Json::Value& json );
};

/***************以下函数用于读取json静态数据***************/
unsigned int    to_uint(const Json::Value& val);
double          to_double(const Json::Value& val);
const char*     to_str(const Json::Value& val);

#endif  //CONFIG_JSONCONFIG_H_
