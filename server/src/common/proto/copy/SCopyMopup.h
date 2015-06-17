#ifndef _SCopyMopup_H_
#define _SCopyMopup_H_

#include <weedong/core/seq/seq.h>
class SCopyMopup : public wd::CSeq
{
public:
    std::map< uint32, uint32 > normal_round;    //普通副本boss击杀最小阵亡人数
    std::map< uint32, uint32 > elite_round;    //精英副本boss击杀最小阵亡人数
    std::map< uint32, uint32 > normal_times;    //普通副本boss扫荡次数, < boss_id, 次数 >
    std::map< uint32, uint32 > elite_times;    //精英副本boss扫荡次数, < boss_id, 次数 >
    std::map< uint32, uint32 > normal_reset;    //普通副本boss重置次数
    std::map< uint32, uint32 > elite_reset;    //精英副本boss重置次数

    SCopyMopup()
    {
    }

    virtual ~SCopyMopup()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SCopyMopup(*this) );
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
            && TFVarTypeProcess( normal_round, eType, stream, uiSize )
            && TFVarTypeProcess( elite_round, eType, stream, uiSize )
            && TFVarTypeProcess( normal_times, eType, stream, uiSize )
            && TFVarTypeProcess( elite_times, eType, stream, uiSize )
            && TFVarTypeProcess( normal_reset, eType, stream, uiSize )
            && TFVarTypeProcess( elite_reset, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SCopyMopup";
    }
};

#endif
