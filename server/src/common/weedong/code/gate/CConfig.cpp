#include "CConfig.h"
#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

CConfig* CConfig::s_Instance = NULL;

CConfig::CConfig()
    :    m_ID(0)
{
    //ctor
}

CConfig::~CConfig()
{
    //dtor
}

CConfig* CConfig::GetInstance(void)
{
    if (s_Instance == NULL)
        s_Instance = new CConfig;
    return s_Instance;
}

bool CConfig::Initialize(int id, const char* config_xml)
{
    if (config_xml == NULL)
        return false;

    xmlDocPtr doc;
    xmlNodePtr cur, child, child2;

    doc = xmlReadFile(config_xml, "UTF-8", 256);

    if (doc == NULL)
        return -1;

    cur = xmlDocGetRootElement(doc);

    if (cur == NULL)
        return -1;

    cur = cur->xmlChildrenNode;

    if (cur == NULL)
        return -1;

    while (cur != NULL)
    {
        if (strcmp((const char*) cur->name, "gates") == 0)
        {
            child = cur->xmlChildrenNode;

            while (child != NULL)
            {
                GateConfig gate;
                gate.id = atoi((char*) xmlGetProp(child, (xmlChar*) "id"));
                strcpy(gate.ip, (char*) xmlGetProp(child, (xmlChar*) "ip"));
                gate.public_port = atoi((char*) xmlGetProp(child, (xmlChar*) "public_port"));
                gate.port = atoi((char*) xmlGetProp(child, (xmlChar*) "port"));

                child2 = child->xmlChildrenNode;
                while (child2 != NULL)
                {
                    strcpy(gate.send_to.ip, (char*) xmlGetProp(child2, (xmlChar*) "ip"));
                    gate.send_to.port = atoi((char*) xmlGetProp(child2, (xmlChar*) "port"));
                    child2 = child2->next;
                }

                m_GateConfigMap[gate.id] = gate;

                child = child->next;
            }
        }

        cur = cur->next;
    }

     m_ID = id;

    return true;
}

const CConfig::GateConfig* CConfig::GetGateConfig(int id)
{
    GateConfigMap::iterator iter = m_GateConfigMap.find(id);

    if (iter == m_GateConfigMap.end())
        return NULL;

    return &iter->second;
}
