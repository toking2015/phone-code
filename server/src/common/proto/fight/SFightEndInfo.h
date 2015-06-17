#ifndef _SFightEndInfo_H_
#define _SFightEndInfo_H_

#include <weedong/core/seq/seq.h>
class SFightEndInfo : public wd::CSeq
{
public:
    uint32 camp;    //阵型
    uint32 round;    //回合
    uint32 hurt;    //攻击总伤害
    uint32 attack_count;    //攻击次数
    uint32 dodge_count;    //闪避次数
    uint32 recover;    //恢复血量
    uint32 magic_hurt;    //魔法伤害
    uint32 dead_count;    //死亡次数 

    SFightEndInfo() : camp(0), round(0), hurt(0), attack_count(0), dodge_count(0), recover(0), magic_hurt(0), dead_count(0)
    {
    }

    virtual ~SFightEndInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightEndInfo(*this) );
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
            && TFVarTypeProcess( camp, eType, stream, uiSize )
            && TFVarTypeProcess( round, eType, stream, uiSize )
            && TFVarTypeProcess( hurt, eType, stream, uiSize )
            && TFVarTypeProcess( attack_count, eType, stream, uiSize )
            && TFVarTypeProcess( dodge_count, eType, stream, uiSize )
            && TFVarTypeProcess( recover, eType, stream, uiSize )
            && TFVarTypeProcess( magic_hurt, eType, stream, uiSize )
            && TFVarTypeProcess( dead_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightEndInfo";
    }
};

#endif
