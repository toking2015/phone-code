#ifndef _SFightSoldierSimple_H_
#define _SFightSoldierSimple_H_

#include <weedong/core/seq/seq.h>
/*战斗人员简单信息*/
class SFightSoldierSimple : public wd::CSeq
{
public:
    uint32 guid;    //唯一标识
    uint32 soldier_guid;    //人物的情况下是武将GUID totem的情况下是totemextid 怪物情况下就是monsterid
    uint16 attr;    //人物标识 玩家/怪物
    uint32 hp;    //武将当前血量
    uint32 rage;    //玩家怒气

    SFightSoldierSimple() : guid(0), soldier_guid(0), attr(0), hp(0), rage(0)
    {
    }

    virtual ~SFightSoldierSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightSoldierSimple(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_guid, eType, stream, uiSize )
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( hp, eType, stream, uiSize )
            && TFVarTypeProcess( rage, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightSoldierSimple";
    }
};

#endif
