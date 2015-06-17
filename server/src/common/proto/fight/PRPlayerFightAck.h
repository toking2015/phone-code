#ifndef _PRPlayerFightAck_H_
#define _PRPlayerFightAck_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightSkillObject.h>

/*战斗技能返回*/
class PRPlayerFightAck : public SMsgHead
{
public:
    uint32 fight_id;
    uint32 seqno;
    SFightSkillObject skill_obj;

    PRPlayerFightAck() : fight_id(0), seqno(0)
    {
        msg_cmd = 1398910108;
    }

    virtual ~PRPlayerFightAck()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPlayerFightAck(*this) );
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
            && TFVarTypeProcess( seqno, eType, stream, uiSize )
            && TFVarTypeProcess( skill_obj, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPlayerFightAck";
    }
};

#endif
