#ifndef _SSoldierSkill_H_
#define _SSoldierSkill_H_

#include <weedong/core/seq/seq.h>
/*武将-技能等级*/
class SSoldierSkill : public wd::CSeq
{
public:
    uint32 id;    //技能id
    uint32 level;    //技能等级

    SSoldierSkill() : id(0), level(0)
    {
    }

    virtual ~SSoldierSkill()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSoldierSkill(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSoldierSkill";
    }
};

#endif
