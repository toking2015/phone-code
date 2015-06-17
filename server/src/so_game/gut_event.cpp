#include "gut_event.h"
#include "task_event.h"
#include "resource/r_gutext.h"
#include "resource/r_taskext.h"
#include "gut_imp.h"
#include "coin_imp.h"

EVENT_FUNC( gut, SEventGutStepCommit )
{
    CGutData::SData* gut = theGutExt.Find( ev.gut_id, ev.index + 1 );
    if ( gut == NULL )
        return;

    if ( gut->take_coin.cate != 0 )
        coin::take( ev.user, gut->take_coin, ev.path );
}

EVENT_FUNC( gut, SEventTaskAccept )
{
    CTaskData::SData* task = theTaskExt.Find( ev.task_id );
    if ( task == NULL )
        return;

    if ( task->begin_gut == 0 )
        return;

    ev.user->data.gut = gut::alloc( ev.user, task->begin_gut );

    gut::reply_gut_info( ev.user, ev.user->data.gut );
}

EVENT_FUNC( gut, SEventTaskFinished )
{
    CTaskData::SData* task = theTaskExt.Find( ev.task_id );
    if ( task == NULL )
        return;

    if ( task->end_gut == 0 )
        return;

    ev.user->data.gut = gut::alloc( ev.user, task->end_gut );

    gut::reply_gut_info( ev.user, ev.user->data.gut );
}

