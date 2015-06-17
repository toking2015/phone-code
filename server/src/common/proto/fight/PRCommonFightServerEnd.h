#ifndef _PRCommonFightServerEnd_H_
#define _PRCommonFightServerEnd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightPlayerInfo.h>
#include <proto/fight/SFightEndInfo.h>
#include <proto/common/S3UInt32.h>

class PRCommonFightServerEnd : public SMsgHead
{
public:
    uint32 fight_id;    //战斗
    std::vector< SFightOrder > order_list;    //战斗技能出手LOG
    uint32 fight_type;    //战斗类型
    uint32 fight_randomseed;    //战斗随机种子
    std::vector< SFightPlayerInfo > fight_info_list;
    uint32 win_camp;    //战斗胜利方
    uint32 is_roundout;    //是否回合超时
    std::map< uint32, SFightEndInfo > fightEndInfo;    //战斗结束信息
    std::vector< S3UInt32 > coins_list;    //战斗奖励

    PRCommonFightServerEnd() : fight_id(0), fight_type(0), fight_randomseed(0), win_camp(0), is_roundout(0)
    {
        msg_cmd = 1338160097;
    }

    virtual ~PRCommonFightServerEnd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCommonFightServerEnd(*this) );
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
            && TFVarTypeProcess( order_list, eType, stream, uiSize )
            && TFVarTypeProcess( fight_type, eType, stream, uiSize )
            && TFVarTypeProcess( fight_randomseed, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && TFVarTypeProcess( win_camp, eType, stream, uiSize )
            && TFVarTypeProcess( is_roundout, eType, stream, uiSize )
            && TFVarTypeProcess( fightEndInfo, eType, stream, uiSize )
            && TFVarTypeProcess( coins_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCommonFightServerEnd";
    }
};

#endif
