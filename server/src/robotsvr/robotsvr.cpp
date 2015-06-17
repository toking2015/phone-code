#include "parammgr.h"
#include "master.h"
#include "test.h"

STestInfo g_info;

void ParamLog(std::vector<std::string> params)
{
    CLog4cxx::read(params[0].c_str());
}

void ParamHost(std::vector<std::string> params)
{
    g_info.host = params[0];
}

void ParamPort(std::vector<std::string> params)
{
    g_info.port = atoi(params[0].c_str());
}

void ParamMsgFile(std::vector<std::string> params)
{
    g_info.msg_file = params[0];
}

void ParamUID(std::vector<std::string> params)
{
    g_info.uid.first  = atoi(params[0].c_str());
    g_info.uid.second = atoi(params[1].c_str());
}

int main(int argc, char** argv)
{
    // 参数
    std::string param_error;
    theParamMgr.bind("-l",    1, ParamLog);
    theParamMgr.bind("-host", 1, ParamHost);
    theParamMgr.bind("-port", 1, ParamPort);
    theParamMgr.bind("-msg",  1, ParamMsgFile);
    theParamMgr.bind("-uid",  2, ParamUID);
    if(!theParamMgr.run(argc, argv, param_error))
    {
        LOG_ERROR(param_error.c_str());
        exit(0);
    }

    // GET MSG FILE SIZE
    FILE * file = fopen(g_info.msg_file.c_str(), "r");
    fseek(file, 0L, SEEK_END);
    g_info.msg_file_size = ftell(file);
    fclose(file);

    if(daemon(1, 0) == -1)
    {
        exit(-1);
    }

    // TEST
    LOG_INFO("TEST PARAMS: HOST=%s, PORT=%u, MSG[%s, %uB], UID[%u, %u]",
        g_info.host.c_str(), g_info.port, g_info.msg_file.c_str(), g_info.msg_file_size, g_info.uid.first, g_info.uid.second);
    theTest.SetInfo(g_info);

    theMaster.Start();

    // 主线程逻辑处理
    for(;;)
    {
        wd::thread_sleep(100000);
    }

    exit(0);
}
