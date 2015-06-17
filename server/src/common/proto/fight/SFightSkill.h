#ifndef _SFightSkill_H_
#define _SFightSkill_H_

#include <weedong/core/seq/seq.h>
/*战斗技能*/
class SFightSkill : public wd::CSeq
{
public:
    uint32 skill_id;    //战斗技能id
    uint32 skill_level;    //战斗技能等级

    SFightSkill() : skill_id(0), skill_level(0)
    {
    }

    virtual ~SFightSkill()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightSkill(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( skill_id, eType, stream, uiSize )
            && TFVarTypeProcess( skill_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightSkill";
    }
};

#endif
