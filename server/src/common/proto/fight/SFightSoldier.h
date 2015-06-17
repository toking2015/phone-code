#ifndef _SFightSoldier_H_
#define _SFightSoldier_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightSoldierSimple.h>
#include <proto/fight/SFightExtAble.h>
#include <proto/item/SUserItem.h>
#include <proto/fight/SFightSkill.h>
#include <proto/fight/SFightOdd.h>
#include <proto/fight/SFightOrder.h>
#include <proto/common/S2UInt32.h>
#include <proto/totem/STotem.h>
#include <proto/totem/STotemGlyph.h>

/*战斗人员信息*/
class SFightSoldier : public SFightSoldierSimple
{
public:
    uint32 soldier_id;    //武将ID,怪物ID,战宠Id
    uint32 fame;    //声望
    std::string name;    //武将名称
    std::string platform_str;    //平台名字
    uint32 platform;    //平台id+服务器id
    uint16 avatar;    //玩家头像
    uint16 quality;    //品质
    uint32 occupation;    //玩家职业
    uint32 equip_type;    //装备类型
    uint8 gender;    //玩家性别
    uint16 horse_id;    //马id
    uint32 level;    //玩家等级
    uint32 fight_index;    //当前位置
    SFightExtAble fight_ext_able;    //武将二级属性
    std::vector< SUserItem > item_list;    //角色装备
    std::vector< SFightSkill > skill_list;    //技能列表
    std::vector< SFightOdd > odd_list;    //BUFF列表
    SFightOrder order;    //使用技能
    SFightExtAble last_ext_able;    //当前武将二级属性
    std::map< uint32, uint32 > lastOrderRound;    //上次使用技能的时间
    std::map< uint32, uint32 > limitCountAll;    //使用BUFF的次数
    std::map< uint32, uint32 > state_list;    //状态信息
    uint32 delFlag;    //删除标志
    uint32 selfUserGuid;    //UserGuid
    uint32 selfFightId;    //战斗ID
    uint32 isPlay;    //是否在播放前置动画阶段
    uint32 deadFlag;    //死亡标志
    std::vector< S2UInt32 > glyph_list;    //图腾给该soldier所加的属性
    STotem totem;    // 如果是图腾，则图腾的信息
    std::vector< STotemGlyph > totem_glyph_list;    // 如果是图腾，则为图腾镶嵌的雕文列表

    SFightSoldier() : soldier_id(0), fame(0), platform(0), avatar(0), quality(0), occupation(0), equip_type(0), gender(0), horse_id(0), level(0), fight_index(0), delFlag(0), selfUserGuid(0), selfFightId(0), isPlay(0), deadFlag(0)
    {
    }

    virtual ~SFightSoldier()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightSoldier(*this) );
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
        return SFightSoldierSimple::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( soldier_id, eType, stream, uiSize )
            && TFVarTypeProcess( fame, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( platform_str, eType, stream, uiSize )
            && TFVarTypeProcess( platform, eType, stream, uiSize )
            && TFVarTypeProcess( avatar, eType, stream, uiSize )
            && TFVarTypeProcess( quality, eType, stream, uiSize )
            && TFVarTypeProcess( occupation, eType, stream, uiSize )
            && TFVarTypeProcess( equip_type, eType, stream, uiSize )
            && TFVarTypeProcess( gender, eType, stream, uiSize )
            && TFVarTypeProcess( horse_id, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( fight_index, eType, stream, uiSize )
            && TFVarTypeProcess( fight_ext_able, eType, stream, uiSize )
            && TFVarTypeProcess( item_list, eType, stream, uiSize )
            && TFVarTypeProcess( skill_list, eType, stream, uiSize )
            && TFVarTypeProcess( odd_list, eType, stream, uiSize )
            && TFVarTypeProcess( order, eType, stream, uiSize )
            && TFVarTypeProcess( last_ext_able, eType, stream, uiSize )
            && TFVarTypeProcess( lastOrderRound, eType, stream, uiSize )
            && TFVarTypeProcess( limitCountAll, eType, stream, uiSize )
            && TFVarTypeProcess( state_list, eType, stream, uiSize )
            && TFVarTypeProcess( delFlag, eType, stream, uiSize )
            && TFVarTypeProcess( selfUserGuid, eType, stream, uiSize )
            && TFVarTypeProcess( selfFightId, eType, stream, uiSize )
            && TFVarTypeProcess( isPlay, eType, stream, uiSize )
            && TFVarTypeProcess( deadFlag, eType, stream, uiSize )
            && TFVarTypeProcess( glyph_list, eType, stream, uiSize )
            && TFVarTypeProcess( totem, eType, stream, uiSize )
            && TFVarTypeProcess( totem_glyph_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightSoldier";
    }
};

#endif
