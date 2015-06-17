#include "event.h"

//针对用户的活动开启事件( 活动期间内在线仅且通知一次 )
struct SEventActivityUserOpen : public SEvent
{
    std::string activity_name;
    SEventActivityUserOpen( SUser* u, uint32 p, std::string n ) : SEvent(u, p), activity_name(n){}
};

//针对用户的活动关闭事件( 活动结束后在线仅且通知一次 )
struct SEventActivityUserClose : public SEvent
{
    std::string activity_name;
    SEventActivityUserClose( SUser* u, uint32 p, std::string n ) : SEvent(u, p), activity_name(n){}
};

//用户参加活动后被调用, 由各个活动自行调用本事件, 并非自动触发
struct SEventActivityUserJoin : public SEvent
{
    std::string activity_name;
    SEventActivityUserJoin( SUser* u, uint32 p, std::string n ) : SEvent(u, p), activity_name(n){}
};

