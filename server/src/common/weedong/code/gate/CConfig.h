#ifndef CCONFIG_H
#define CCONFIG_H

#include <list>
#include <map>

class CConfig
{
public:
    struct SendToConfig
    {
        char ip[128];   // 转发的IP
        int port;   // 转发的端口
    };
    struct GateConfig
    {
        int id;         // 服务器ID
        char ip[128];
        int public_port;    // 对外服务端口
        int port;   // 服务端口
        SendToConfig    send_to;    // 转发链表
    };
public:
    CConfig();
    virtual ~CConfig();

    static CConfig* GetInstance(void);

    int GetID(void) const   {return m_ID;}

    // 初始化网关配置
    bool Initialize(int id, const char* config_xml);

    // 读取网关配置
    const GateConfig* GetGateConfig(int id);

private:
    static CConfig* s_Instance;
    int m_ID;
    typedef std::map<int, GateConfig>   GateConfigMap;
    GateConfigMap   m_GateConfigMap;
};

#endif // CCONFIG_H
