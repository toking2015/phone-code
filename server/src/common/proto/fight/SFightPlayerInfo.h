#ifndef _SFightPlayerInfo_H_
#define _SFightPlayerInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightSoldier.h>

/*战斗团队信息*/
class SFightPlayerInfo : public wd::CSeq
{
public:
    uint32 guid;    //唯一id
    uint32 player_guid;    //玩家GUID
    uint16 camp;    //用这个来标识阵营
    uint16 attr;    //人物标识 玩家/怪物
    uint32 flag;    //状态
    uint32 isAutoFight;    //自动战斗
    uint32 totem_value;    //totem值
    std::vector< SFightSoldier > soldier_list;    //玩家武将

    SFightPlayerInfo() : guid(0), player_guid(0), camp(0), attr(0), flag(0), isAutoFight(0), totem_value(0)
    {
    }

    virtual ~SFightPlayerInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightPlayerInfo(*this) );
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
            && TFVarTypeProcess( player_guid, eType, stream, uiSize )
            && TFVarTypeProcess( camp, eType, stream, uiSize )
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && TFVarTypeProcess( isAutoFight, eType, stream, uiSize )
            && TFVarTypeProcess( totem_value, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightPlayerInfo";
    }
};

#endif
