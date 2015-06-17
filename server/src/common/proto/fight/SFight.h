#ifndef _SFight_H_
#define _SFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SSoldier.h>
#include <proto/fight/SFightPlayerInfo.h>
#include <proto/fight/SFightPlayerSimple.h>
#include <proto/fight/SFightRecord.h>
#include <proto/fight/SFightEndInfo.h>

class SFight : public wd::CSeq
{
public:
    uint32 fight_id;    //战斗id
    uint16 fight_type;    //战斗类型
    uint32 create_time;    //创建时间
    uint32 gc_time;    //删除时间
    uint32 box_randomseed;    //宝箱随机种子
    uint32 fight_randomseed;    //战斗随机种子
    uint32 loop_id;    //回调的id
    uint16 win_camp;    //胜利
    uint32 ack_id;    //挑战者Id
    uint32 def_id;    //应战者Id
    std::vector< SSoldier > soldier_list;    //参战玩家
    std::vector< SSoldier > monster_list;    //参战怪物
    uint32 help_monster;    //帮忙怪
    std::vector< SFightPlayerInfo > fight_info_list;
    std::vector< SFightPlayerSimple > soldierEndList;
    uint16 state;    //状态 CreateOK DataOK
    uint32 seqno;    //双人战斗同步id
    std::map< uint32, uint32 > seqno_map;    //user_guid, seqno
    SFightRecord fight_record;    //战斗LOG保存信息
    std::map< uint32, SFightEndInfo > fightEndInfo;    //战斗结束的信息
    uint32 is_quit;    //是否是撤退
    uint32 is_roundout;    //是否超时

    SFight() : fight_id(0), fight_type(0), create_time(0), gc_time(0), box_randomseed(0), fight_randomseed(0), loop_id(0), win_camp(0), ack_id(0), def_id(0), help_monster(0), state(0), seqno(0), is_quit(0), is_roundout(0)
    {
    }

    virtual ~SFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFight(*this) );
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
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_type, eType, stream, uiSize )
            && TFVarTypeProcess( create_time, eType, stream, uiSize )
            && TFVarTypeProcess( gc_time, eType, stream, uiSize )
            && TFVarTypeProcess( box_randomseed, eType, stream, uiSize )
            && TFVarTypeProcess( fight_randomseed, eType, stream, uiSize )
            && TFVarTypeProcess( loop_id, eType, stream, uiSize )
            && TFVarTypeProcess( win_camp, eType, stream, uiSize )
            && TFVarTypeProcess( ack_id, eType, stream, uiSize )
            && TFVarTypeProcess( def_id, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_list, eType, stream, uiSize )
            && TFVarTypeProcess( monster_list, eType, stream, uiSize )
            && TFVarTypeProcess( help_monster, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && TFVarTypeProcess( soldierEndList, eType, stream, uiSize )
            && TFVarTypeProcess( state, eType, stream, uiSize )
            && TFVarTypeProcess( seqno, eType, stream, uiSize )
            && TFVarTypeProcess( seqno_map, eType, stream, uiSize )
            && TFVarTypeProcess( fight_record, eType, stream, uiSize )
            && TFVarTypeProcess( fightEndInfo, eType, stream, uiSize )
            && TFVarTypeProcess( is_quit, eType, stream, uiSize )
            && TFVarTypeProcess( is_roundout, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFight";
    }
};

#endif
