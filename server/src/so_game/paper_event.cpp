#include "paper_imp.h"
#include "user_event.h"
#include "copy_event.h"

EVENT_FUNC(paper, SEventUserTimeLimit)
{
    paper::TimeLimit(ev.user);
}

EVENT_FUNC(paper, SEventUserMeet)
{
    paper::CopyMaterialRefresh(ev.user);
}
