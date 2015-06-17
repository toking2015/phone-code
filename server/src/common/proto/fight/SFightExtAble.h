#ifndef _SFightExtAble_H_
#define _SFightExtAble_H_

#include <weedong/core/seq/seq.h>
/*战斗属性*/
class SFightExtAble : public wd::CSeq
{
public:
    uint32 hp;    //气血
    uint32 physical_ack;    //物理攻击
    uint32 physical_def;    //物理防御
    uint32 magic_ack;    //法术攻击
    uint32 magic_def;    //法术防御
    uint32 speed;    //速度
    uint32 critper;    //暴击率
    uint32 critper_def;    //暴击抵抗
    uint32 recover_critper;    //回血暴击率
    uint32 recover_critper_def;    //回血暴击抵抗
    uint32 crithurt;    //暴击伤害
    uint32 crithurt_def;    //暴击减免
    uint32 hitper;    //命中
    uint32 dodgeper;    //闪避
    uint32 parryper;    //格挡
    uint32 parryper_dec;    //格挡减少
    uint32 rage;    //蓄力值
    uint32 stun_def;    //眩晕抗性
    uint32 silent_def;    //沉默抗性
    uint32 weak_def;    //虚弱抗性
    uint32 fire_def;    //烧伤抗性
    uint32 recover_add_fix;    //回血固定值
    uint32 recover_del_fix;    //回血固定值
    uint32 recover_add_per;    //回血百分比
    uint32 recover_del_per;    //回血百分比
    uint32 rage_add_fix;    //怒气固定值
    uint32 rage_del_fix;    //怒气固定值
    uint32 rage_add_per;    //怒气百分比
    uint32 rage_del_per;    //怒气百分比

    SFightExtAble() : hp(0), physical_ack(0), physical_def(0), magic_ack(0), magic_def(0), speed(0), critper(0), critper_def(0), recover_critper(0), recover_critper_def(0), crithurt(0), crithurt_def(0), hitper(0), dodgeper(0), parryper(0), parryper_dec(0), rage(0), stun_def(0), silent_def(0), weak_def(0), fire_def(0), recover_add_fix(0), recover_del_fix(0), recover_add_per(0), recover_del_per(0), rage_add_fix(0), rage_del_fix(0), rage_add_per(0), rage_del_per(0)
    {
    }

    virtual ~SFightExtAble()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightExtAble(*this) );
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
            && TFVarTypeProcess( hp, eType, stream, uiSize )
            && TFVarTypeProcess( physical_ack, eType, stream, uiSize )
            && TFVarTypeProcess( physical_def, eType, stream, uiSize )
            && TFVarTypeProcess( magic_ack, eType, stream, uiSize )
            && TFVarTypeProcess( magic_def, eType, stream, uiSize )
            && TFVarTypeProcess( speed, eType, stream, uiSize )
            && TFVarTypeProcess( critper, eType, stream, uiSize )
            && TFVarTypeProcess( critper_def, eType, stream, uiSize )
            && TFVarTypeProcess( recover_critper, eType, stream, uiSize )
            && TFVarTypeProcess( recover_critper_def, eType, stream, uiSize )
            && TFVarTypeProcess( crithurt, eType, stream, uiSize )
            && TFVarTypeProcess( crithurt_def, eType, stream, uiSize )
            && TFVarTypeProcess( hitper, eType, stream, uiSize )
            && TFVarTypeProcess( dodgeper, eType, stream, uiSize )
            && TFVarTypeProcess( parryper, eType, stream, uiSize )
            && TFVarTypeProcess( parryper_dec, eType, stream, uiSize )
            && TFVarTypeProcess( rage, eType, stream, uiSize )
            && TFVarTypeProcess( stun_def, eType, stream, uiSize )
            && TFVarTypeProcess( silent_def, eType, stream, uiSize )
            && TFVarTypeProcess( weak_def, eType, stream, uiSize )
            && TFVarTypeProcess( fire_def, eType, stream, uiSize )
            && TFVarTypeProcess( recover_add_fix, eType, stream, uiSize )
            && TFVarTypeProcess( recover_del_fix, eType, stream, uiSize )
            && TFVarTypeProcess( recover_add_per, eType, stream, uiSize )
            && TFVarTypeProcess( recover_del_per, eType, stream, uiSize )
            && TFVarTypeProcess( rage_add_fix, eType, stream, uiSize )
            && TFVarTypeProcess( rage_del_fix, eType, stream, uiSize )
            && TFVarTypeProcess( rage_add_per, eType, stream, uiSize )
            && TFVarTypeProcess( rage_del_per, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightExtAble";
    }
};

#endif
