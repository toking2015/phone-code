#ifndef _SUserSimple_H_
#define _SUserSimple_H_

#include <weedong/core/seq/seq.h>
/*用户简易信息结构*/
class SUserSimple : public wd::CSeq
{
public:
    std::string platform;
    std::string name;
    uint8 gender;    //性别
    uint16 avatar;    //头像信息
    uint32 team_level;    //战队等级
    uint32 team_xp;    //战队经验
    uint32 vip_level;    //vip等级
    uint32 vip_xp;    //vip经验
    uint32 fight_value;    //战斗力
    uint32 strength;    //体力点
    uint32 guild_id;    //公会Id

    SUserSimple() : gender(0), avatar(0), team_level(0), team_xp(0), vip_level(0), vip_xp(0), fight_value(0), strength(0), guild_id(0)
    {
    }

    virtual ~SUserSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserSimple(*this) );
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
            && TFVarTypeProcess( platform, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( gender, eType, stream, uiSize )
            && TFVarTypeProcess( avatar, eType, stream, uiSize )
            && TFVarTypeProcess( team_level, eType, stream, uiSize )
            && TFVarTypeProcess( team_xp, eType, stream, uiSize )
            && TFVarTypeProcess( vip_level, eType, stream, uiSize )
            && TFVarTypeProcess( vip_xp, eType, stream, uiSize )
            && TFVarTypeProcess( fight_value, eType, stream, uiSize )
            && TFVarTypeProcess( strength, eType, stream, uiSize )
            && TFVarTypeProcess( guild_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserSimple";
    }
};

#endif
