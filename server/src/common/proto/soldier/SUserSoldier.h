#ifndef _SUserSoldier_H_
#define _SUserSoldier_H_

#include <weedong/core/seq/seq.h>
#include <proto/soldier/SSoldierSkill.h>

/*武将-印佳*/
class SUserSoldier : public wd::CSeq
{
public:
    uint32 guid;    //惟一标识
    uint32 soldier_id;    //武将ID
    uint32 soldier_type;    //武将类型
    uint16 soldier_index;    //索引
    uint16 level;    //等级
    uint32 xp;    //XP
    uint16 quality;    //品质
    uint32 quality_lv;    //不再使用
    uint32 quality_xp;    //品质经验
    uint16 star;    //星级
    uint32 hp;    //HP
    uint32 mp;    //MP
    std::vector< SSoldierSkill > skill_list;    //技能LIST

    SUserSoldier() : guid(0), soldier_id(0), soldier_type(0), soldier_index(0), level(0), xp(0), quality(0), quality_lv(0), quality_xp(0), star(0), hp(0), mp(0)
    {
    }

    virtual ~SUserSoldier()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserSoldier(*this) );
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
            && TFVarTypeProcess( soldier_id, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_type, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_index, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( xp, eType, stream, uiSize )
            && TFVarTypeProcess( quality, eType, stream, uiSize )
            && TFVarTypeProcess( quality_lv, eType, stream, uiSize )
            && TFVarTypeProcess( quality_xp, eType, stream, uiSize )
            && TFVarTypeProcess( star, eType, stream, uiSize )
            && TFVarTypeProcess( hp, eType, stream, uiSize )
            && TFVarTypeProcess( mp, eType, stream, uiSize )
            && TFVarTypeProcess( skill_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserSoldier";
    }
};

#endif
