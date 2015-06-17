#include "proto/transfrom/transfrom_task.h"

#include "proto/task/SUserTask.h"
#include "proto/task/SUserTaskLog.h"
#include "proto/task/SUserTaskDay.h"
#include "proto/task/PQTaskList.h"
#include "proto/task/PRTaskList.h"
#include "proto/task/PQTaskLogList.h"
#include "proto/task/PRTaskLogList.h"
#include "proto/task/PQTaskAccept.h"
#include "proto/task/PQTaskFinish.h"
#include "proto/task/PQTaskAutoFinish.h"
#include "proto/task/PQTaskSet.h"
#include "proto/task/PRTaskSet.h"
#include "proto/task/PRTaskLog.h"
#include "proto/task/PRTaskDay.h"
#include "proto/task/PRTaskDayList.h"
#include "proto/task/PQTaskDayValReward.h"
#include "proto/task/PRTaskDayValReward.h"
#include "proto/task/PRTaskDayValRewardList.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_task::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 848369111 ] = std::make_pair( "PQTaskList", msg_transfrom< PQTaskList > );
    handles[ 1480421482 ] = std::make_pair( "PRTaskList", msg_transfrom< PRTaskList > );
    handles[ 690366673 ] = std::make_pair( "PQTaskLogList", msg_transfrom< PQTaskLogList > );
    handles[ 1234819902 ] = std::make_pair( "PRTaskLogList", msg_transfrom< PRTaskLogList > );
    handles[ 896801999 ] = std::make_pair( "PQTaskAccept", msg_transfrom< PQTaskAccept > );
    handles[ 403585854 ] = std::make_pair( "PQTaskFinish", msg_transfrom< PQTaskFinish > );
    handles[ 869618664 ] = std::make_pair( "PQTaskAutoFinish", msg_transfrom< PQTaskAutoFinish > );
    handles[ 3607773 ] = std::make_pair( "PQTaskSet", msg_transfrom< PQTaskSet > );
    handles[ 2040321963 ] = std::make_pair( "PRTaskSet", msg_transfrom< PRTaskSet > );
    handles[ 2119306534 ] = std::make_pair( "PRTaskLog", msg_transfrom< PRTaskLog > );
    handles[ 1238179220 ] = std::make_pair( "PRTaskDay", msg_transfrom< PRTaskDay > );
    handles[ 1843551594 ] = std::make_pair( "PRTaskDayList", msg_transfrom< PRTaskDayList > );
    handles[ 994921066 ] = std::make_pair( "PQTaskDayValReward", msg_transfrom< PQTaskDayValReward > );
    handles[ 1981998351 ] = std::make_pair( "PRTaskDayValReward", msg_transfrom< PRTaskDayValReward > );
    handles[ 1705235466 ] = std::make_pair( "PRTaskDayValRewardList", msg_transfrom< PRTaskDayValRewardList > );

    return handles;
}

