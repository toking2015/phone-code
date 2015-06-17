#ifndef _SFightSkillObject_H_
#define _SFightSkillObject_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightSoldierSimple.h>

/*战斗技能以及对象*/
class SFightSkillObject : public wd::CSeq
{
public:
    uint32 round;    //当前回合
    SFightOrder order;
    std::vector< SFightSoldierSimple > targetList;

    SFightSkillObject() : round(0)
    {
    }

    virtual ~SFightSkillObject()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightSkillObject(*this) );
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
            && TFVarTypeProcess( round, eType, stream, uiSize )
            && TFVarTypeProcess( order, eType, stream, uiSize )
            && TFVarTypeProcess( targetList, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightSkillObject";
    }
};

#endif
