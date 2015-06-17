#ifndef _SSingleArenaOpponent_H_
#define _SSingleArenaOpponent_H_

#include <weedong/core/seq/seq.h>
#include <proto/formation/SUserFormation.h>

/*竟技场-王子浪*/
class SSingleArenaOpponent : public wd::CSeq
{
public:
    uint32 target_id;    //对手guid, 少于7位数的为假人
    std::string name;    //对手名字
    uint16 avatar;    //对手头像
    uint32 team_level;    //战队等级
    uint32 rank;    //对手名次
    uint32 fight_value;    //战力，假人
    std::vector< SUserFormation > formation_list;    //阵型     //如果此结构体做为排行榜数据，这list总为空

    SSingleArenaOpponent() : target_id(0), avatar(0), team_level(0), rank(0), fight_value(0)
    {
    }

    virtual ~SSingleArenaOpponent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSingleArenaOpponent(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( avatar, eType, stream, uiSize )
            && TFVarTypeProcess( team_level, eType, stream, uiSize )
            && TFVarTypeProcess( rank, eType, stream, uiSize )
            && TFVarTypeProcess( fight_value, eType, stream, uiSize )
            && TFVarTypeProcess( formation_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSingleArenaOpponent";
    }
};

#endif
