#ifndef _GAMESVR_COMMANDIMP_H_
#define _GAMESVR_COMMANDIMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/user.h"
#include "proto/item.h"
#include "resource/r_itemext.h"
#include "dynamicmgr.h"

//服务端方面用于测试部分
namespace command
{
    typedef bool (*FuncHandler)(SUser* puser, Tokens& tokens);
    typedef std::map<std::string, FuncHandler > StrFuncMap;
    static StrFuncMap name_func_map;

    bool    Parse(SUser* user, std::string& content);
    //建立模块功能
    void    Build(void);
};

#endif  //_GAMESVR_COMMANDIMP_H_
