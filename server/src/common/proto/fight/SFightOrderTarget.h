#ifndef _SFightOrderTarget_H_
#define _SFightOrderTarget_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightOddSet.h>
#include <proto/fight/SFightOddTriggered.h>

/*战斗伤害*/
class SFightOrderTarget : public wd::CSeq
{
public:
    uint32 guid;    //角色ID被打的角色ID
    uint16 attr;    //人物标识 玩家/怪物/宠物
    uint32 rage;    //当前玩家怒气值
    uint32 hp;    //血量
    uint16 fight_attr;    //连击 反击 追击 客户端表现用
    uint16 fight_might;    //第几次攻击
    uint16 fight_result;    //战斗结果 扣血 加血等
    uint16 fight_type;    //战斗类型 暴击 格挡等
    uint32 fight_value;    //战斗值
    uint32 totem_value;    //图腾值
    uint32 max_hp;    //最大血量
    uint32 odd_id;    //oddid造成的伤害
    std::vector< SFightOddSet > odd_list;    //当前玩家ODD变更列表
    std::vector< SFightOddTriggered > odd_list_triggered;    //触发的guid和oddid

    SFightOrderTarget() : guid(0), attr(0), rage(0), hp(0), fight_attr(0), fight_might(0), fight_result(0), fight_type(0), fight_value(0), totem_value(0), max_hp(0), odd_id(0)
    {
    }

    virtual ~SFightOrderTarget()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightOrderTarget(*this) );
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
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( rage, eType, stream, uiSize )
            && TFVarTypeProcess( hp, eType, stream, uiSize )
            && TFVarTypeProcess( fight_attr, eType, stream, uiSize )
            && TFVarTypeProcess( fight_might, eType, stream, uiSize )
            && TFVarTypeProcess( fight_result, eType, stream, uiSize )
            && TFVarTypeProcess( fight_type, eType, stream, uiSize )
            && TFVarTypeProcess( fight_value, eType, stream, uiSize )
            && TFVarTypeProcess( totem_value, eType, stream, uiSize )
            && TFVarTypeProcess( max_hp, eType, stream, uiSize )
            && TFVarTypeProcess( odd_id, eType, stream, uiSize )
            && TFVarTypeProcess( odd_list, eType, stream, uiSize )
            && TFVarTypeProcess( odd_list_triggered, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightOrderTarget";
    }
};

#endif
