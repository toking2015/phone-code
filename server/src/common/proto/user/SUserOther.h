#ifndef _SUserOther_H_
#define _SUserOther_H_

#include <weedong/core/seq/seq.h>
/*用户存储数据库的零散数据，最好是基本类型数据*/
class SUserOther : public wd::CSeq
{
public:
    uint32 single_arena_rank;    //玩家竞技场最高排名
    uint32 single_arena_win_times;    //玩家竞技场战胜次数 注：离线不算
    uint32 paper_skill;    //玩家手工技能
    uint32 mystery_refresh_time;    //神秘商店下次刷新时间戳
    uint32 purview;    //权限[ kBackXXX ]
    uint32 chat_ban_endtime;    //玩家禁言结束时间
    std::string last_action;    //最后行为记录
    uint32 market_day_get;    //拍卖行当天收入
    uint32 market_day_cost;    //拍卖行当天消耗
    uint32 market_day_time;    //拍卖行时间戳
    uint32 market_cost_time;    //拍卖行花费时间戳 market_day_time为获取

    SUserOther() : single_arena_rank(0), single_arena_win_times(0), paper_skill(0), mystery_refresh_time(0), purview(0), chat_ban_endtime(0), market_day_get(0), market_day_cost(0), market_day_time(0), market_cost_time(0)
    {
    }

    virtual ~SUserOther()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserOther(*this) );
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
            && TFVarTypeProcess( single_arena_rank, eType, stream, uiSize )
            && TFVarTypeProcess( single_arena_win_times, eType, stream, uiSize )
            && TFVarTypeProcess( paper_skill, eType, stream, uiSize )
            && TFVarTypeProcess( mystery_refresh_time, eType, stream, uiSize )
            && TFVarTypeProcess( purview, eType, stream, uiSize )
            && TFVarTypeProcess( chat_ban_endtime, eType, stream, uiSize )
            && TFVarTypeProcess( last_action, eType, stream, uiSize )
            && TFVarTypeProcess( market_day_get, eType, stream, uiSize )
            && TFVarTypeProcess( market_day_cost, eType, stream, uiSize )
            && TFVarTypeProcess( market_day_time, eType, stream, uiSize )
            && TFVarTypeProcess( market_cost_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserOther";
    }
};

#endif
