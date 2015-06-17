#ifndef _SUserTomb_H_
#define _SUserTomb_H_

#include <weedong/core/seq/seq.h>
#include <proto/tomb/SUserKillInfo.h>

class SUserTomb : public wd::CSeq
{
public:
    uint32 try_count;    //今天挑战次数 
    uint32 try_count_now;    //当前是第几次挑战
    uint32 win_count;    //胜利次数
    uint32 max_win_count;    //今天最大胜利次数
    uint32 reward_count;    //领奖次数 
    uint32 totem_value_self;    //图腾值自己
    uint32 totem_value_target;    //图腾值对面
    uint32 history_win_count;    //历史上最大胜利次数
    uint32 history_reset_count;    //历史重置次数
    uint32 history_pass_count;    //历史通关次数
    std::vector< SUserKillInfo > history_kill_count;    //历史杀怪记录

    SUserTomb() : try_count(0), try_count_now(0), win_count(0), max_win_count(0), reward_count(0), totem_value_self(0), totem_value_target(0), history_win_count(0), history_reset_count(0), history_pass_count(0)
    {
    }

    virtual ~SUserTomb()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTomb(*this) );
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
            && TFVarTypeProcess( try_count, eType, stream, uiSize )
            && TFVarTypeProcess( try_count_now, eType, stream, uiSize )
            && TFVarTypeProcess( win_count, eType, stream, uiSize )
            && TFVarTypeProcess( max_win_count, eType, stream, uiSize )
            && TFVarTypeProcess( reward_count, eType, stream, uiSize )
            && TFVarTypeProcess( totem_value_self, eType, stream, uiSize )
            && TFVarTypeProcess( totem_value_target, eType, stream, uiSize )
            && TFVarTypeProcess( history_win_count, eType, stream, uiSize )
            && TFVarTypeProcess( history_reset_count, eType, stream, uiSize )
            && TFVarTypeProcess( history_pass_count, eType, stream, uiSize )
            && TFVarTypeProcess( history_kill_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserTomb";
    }
};

#endif
