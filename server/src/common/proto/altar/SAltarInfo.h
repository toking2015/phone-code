#ifndef _SAltarInfo_H_
#define _SAltarInfo_H_

#include <weedong/core/seq/seq.h>
/* 抽奖*/
class SAltarInfo : public wd::CSeq
{
public:
    uint32 reset_time;    // 重置时间
    uint32 free_count;    // 免费次数
    uint32 free_time;    // 免费抽取的时间
    uint32 gold_free_time;    // 钻石免费抽取的时间
    uint32 money_seed_1;
    uint32 money_seed_10;
    uint32 gold_seed_1;
    uint32 gold_seed_10;

    SAltarInfo() : reset_time(0), free_count(0), free_time(0), gold_free_time(0), money_seed_1(0), money_seed_10(0), gold_seed_1(0), gold_seed_10(0)
    {
    }

    virtual ~SAltarInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SAltarInfo(*this) );
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
            && TFVarTypeProcess( reset_time, eType, stream, uiSize )
            && TFVarTypeProcess( free_count, eType, stream, uiSize )
            && TFVarTypeProcess( free_time, eType, stream, uiSize )
            && TFVarTypeProcess( gold_free_time, eType, stream, uiSize )
            && TFVarTypeProcess( money_seed_1, eType, stream, uiSize )
            && TFVarTypeProcess( money_seed_10, eType, stream, uiSize )
            && TFVarTypeProcess( gold_seed_1, eType, stream, uiSize )
            && TFVarTypeProcess( gold_seed_10, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SAltarInfo";
    }
};

#endif
