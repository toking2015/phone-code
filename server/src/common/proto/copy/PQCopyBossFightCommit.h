#ifndef _PQCopyBossFightCommit_H_
#define _PQCopyBossFightCommit_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightPlayerSimple.h>

/*挑战boss战斗确认*/
class PQCopyBossFightCommit : public SMsgHead
{
public:
    uint32 fight_id;    //副本战斗Id
    std::vector< SFightOrder > order_list;    //战斗技能出手LOG 
    std::vector< SFightPlayerSimple > fight_info_list;    //战斗结束时候的信息

    PQCopyBossFightCommit() : fight_id(0)
    {
        msg_cmd = 273326454;
    }

    virtual ~PQCopyBossFightCommit()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyBossFightCommit(*this) );
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
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( order_list, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyBossFightCommit";
    }
};

#endif
