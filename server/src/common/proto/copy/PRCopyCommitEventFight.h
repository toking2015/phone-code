#ifndef _PRCopyCommitEventFight_H_
#define _PRCopyCommitEventFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/copy/PRCopyCommitEvent.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightPlayerSimple.h>

/*失败返回*/
class PRCopyCommitEventFight : public PRCopyCommitEvent
{
public:
    uint32 fight_id;    //战斗id
    std::vector< SFightOrder > order_list;
    std::vector< SFightPlayerSimple > fight_info_list;

    PRCopyCommitEventFight() : fight_id(0)
    {
        msg_cmd = 1091587271;
    }

    virtual ~PRCopyCommitEventFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyCommitEventFight(*this) );
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
        return PRCopyCommitEvent::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( order_list, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyCommitEventFight";
    }
};

#endif
