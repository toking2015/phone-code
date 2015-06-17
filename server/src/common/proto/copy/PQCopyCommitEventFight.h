#ifndef _PQCopyCommitEventFight_H_
#define _PQCopyCommitEventFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/copy/PQCopyCommitEvent.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightPlayerSimple.h>

/*事件验证--战斗*/
class PQCopyCommitEventFight : public PQCopyCommitEvent
{
public:
    uint32 fight_id;    //战斗id
    std::vector< SFightOrder > order_list;    //战斗技能出手LOG
    std::vector< SFightPlayerSimple > fight_info_list;    //战斗结束时候的信息

    PQCopyCommitEventFight() : fight_id(0)
    {
        msg_cmd = 750802594;
    }

    virtual ~PQCopyCommitEventFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyCommitEventFight(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType eType, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return PQCopyCommitEvent::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( order_list, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyCommitEventFight";
    }
};

#endif
