#ifndef _PQSoldierSkillLvUp_H_
#define _PQSoldierSkillLvUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@技能升级*/
class PQSoldierSkillLvUp : public SMsgHead
{
public:
    S2UInt32 soldier;    //武将 first:武将背包类型 second:武将guid
    uint32 skill_id;    //需要升级的技能

    PQSoldierSkillLvUp() : skill_id(0)
    {
        msg_cmd = 9167997;
    }

    virtual ~PQSoldierSkillLvUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierSkillLvUp(*this) );
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
            && TFVarTypeProcess( soldier, eType, stream, uiSize )
            && TFVarTypeProcess( skill_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierSkillLvUp";
    }
};

#endif
