#include "event.h"
#include "formation_imp.h"
#include "proto/formation.h"
#include "user_event.h"

EVENT_FUNC( formation, SEventUserInit )
{
    formation::Init( ev.user, kFormationTypeCommon );
}

