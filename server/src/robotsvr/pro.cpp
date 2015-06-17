#include "test.h"

MSG_FUNC(PRSystemLogin)
{
    theTest.OnLogin(msg);
}

MSG_FUNC(PRSystemSessionCheck)
{
    theTest.OnSessionCheck(msg);
}

MSG_FUNC(PRSystemErrCode)
{
    theTest.OnErrorCode(msg);
}
