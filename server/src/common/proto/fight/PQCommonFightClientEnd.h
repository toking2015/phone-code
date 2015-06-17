#ifndef _PQCommonFightClientEnd_H_
#define _PQCommonFightClientEnd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightPlayerSimple.h>
#include <proto/fight/SFightEndInfo.h>
#include <proto/fight/SFight.h>

class PQCommonFightClientEnd : public SMsgHead
{
public:
    uint32 fight_id;    //战斗
    uint32 win_camp;    //胜利方
    uint32 is_roundout;    //是否超时
    std::vector< SFightOrder > order_list;    //战斗技能出手LOG
    std::vector< SFightPlayerSimple > fight_info_list;    //战斗结束时候的信息
    std::map< uint32, SFightEndInfo > fightEndInfo;    //战斗结束信息
    SFight fight_info_game;    //战斗信息 服务端用 客户端不需要赋值

    PQCommonFightClientEnd() : fight_id(0), win_camp(0), is_roundout(0)
    {
        msg_cmd = 228122789;
    }

    virtual ~PQCommonFightClientEnd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCommonFightClientEnd(*this) );
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
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( win_camp, eType, stream, uiSize )
            && TFVarTypeProcess( is_roundout, eType, stream, uiSize )
            && TFVarTypeProcess( order_list, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && TFVarTypeProcess( fightEndInfo, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_game, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCommonFightClientEnd";
    }
};

#endif
