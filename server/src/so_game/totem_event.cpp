#include "event.h"
#include "user_event.h"
#include "totem_imp.h"

EVENT_FUNC(totem, SEventUserInit)
{
    totem::Add(ev.user, 80301, kPathTotemUserInit);
}

