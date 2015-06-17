#ifndef _SFightPlayerSimple_H_
#define _SFightPlayerSimple_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightSoldierSimple.h>

/*战斗团队信息*/
class SFightPlayerSimple : public wd::CSeq
{
public:
    uint32 guid;    //唯一id
    uint32 player_guid;    //玩家GUID
    uint16 camp;    //用这个来标识阵营
    uint16 attr;    //人物标识 玩家/怪物
    uint32 hurt;    //造成的伤害
    uint32 totem_value;    //totem值
    std::vector< SFightSoldierSimple > soldier_list;    //玩家武将

    SFightPlayerSimple() : guid(0), player_guid(0), camp(0), attr(0), hurt(0), totem_value(0)
    {
    }

    virtual ~SFightPlayerSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightPlayerSimple(*this) );
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
            && TFVarTypeProcess( hurt, eType, stream, uiSize )
            && TFVarTypeProcess( totem_value, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightPlayerSimple";
    }
};

#endif
