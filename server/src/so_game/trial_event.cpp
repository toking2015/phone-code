#include "event.h"
#include "fight_imp.h"
#include "proto/trial.h"
#include "proto/constant.h"
#include "trial_imp.h"
#include "var_imp.h"
#include "user_event.h"

EVENT_FUNC( trial, SEventUserTimeLimit )
{
    trial::TimeLimit(ev.user);
}

