#ifndef _PQAltarLottery_H_
#define _PQAltarLottery_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 抽奖 */
class PQAltarLottery : public SMsgHead
{
public:
    uint32 lottery_type;    // 抽奖类型, kAltarLotteryByMoney或kAltarLotteryByGold
    uint32 lottery_count;    // 抽奖次数
    uint32 use_type;    // 使用类型

    PQAltarLottery() : lottery_type(0), lottery_count(0), use_type(0)
    {
        msg_cmd = 512180379;
    }

    virtual ~PQAltarLottery()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQAltarLottery(*this) );
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
            && TFVarTypeProcess( lottery_type, eType, stream, uiSize )
            && TFVarTypeProcess( lottery_count, eType, stream, uiSize )
            && TFVarTypeProcess( use_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQAltarLottery";
    }
};

#endif
