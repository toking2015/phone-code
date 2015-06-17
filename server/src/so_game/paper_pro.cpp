#include "paper_imp.h"
#include "misc.h"
#include "proto/paper.h"
#include "user_dc.h"

MSG_FUNC(PQPaperLevelUp)
{
    QU_ON( user, msg.role_id );
    paper::LevelUp(user, msg.skill_type);
}

MSG_FUNC(PQPaperForget)
{
    QU_ON( user, msg.role_id );
    paper::Forget(user);
}

MSG_FUNC(PQPaperCreate)
{
    QU_ON( user, msg.role_id );
    paper::CreatePaper(user, msg.paper_id);
}

MSG_FUNC(PQPaperCollect)
{
    QU_ON( user, msg.role_id );
    paper::Collect(user, msg.collect_level);
}
