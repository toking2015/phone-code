#ifndef _SSingleArenaInfo_H_
#define _SSingleArenaInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/singlearena/SSingleArenaOpponent.h>
#include <proto/singlearena/SSingleArenaLog.h>

class SSingleArenaInfo : public wd::CSeq
{
public:
    std::vector< SSingleArenaOpponent > opponent_list;    //对手    
    std::vector< SSingleArenaLog > fightlog_list;    //战斗log
    uint32 cur_rank;    //当前排名
    uint32 max_rank;    //历史最高排名
    uint32 fight_value;    //当前战力
    uint32 time_cd;    //挑战CD
    uint32 add_times;    //增加的挑战次数
    uint32 cur_times;    //当前挑战次数

    SSingleArenaInfo() : cur_rank(0), max_rank(0), fight_value(0), time_cd(0), add_times(0), cur_times(0)
    {
    }

    virtual ~SSingleArenaInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSingleArenaInfo(*this) );
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
            && TFVarTypeProcess( opponent_list, eType, stream, uiSize )
            && TFVarTypeProcess( fightlog_list, eType, stream, uiSize )
            && TFVarTypeProcess( cur_rank, eType, stream, uiSize )
            && TFVarTypeProcess( max_rank, eType, stream, uiSize )
            && TFVarTypeProcess( fight_value, eType, stream, uiSize )
            && TFVarTypeProcess( time_cd, eType, stream, uiSize )
            && TFVarTypeProcess( add_times, eType, stream, uiSize )
            && TFVarTypeProcess( cur_times, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSingleArenaInfo";
    }
};

#endif
