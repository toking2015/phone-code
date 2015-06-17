#ifndef _SUserCoin_H_
#define _SUserCoin_H_

#include <weedong/core/seq/seq.h>
/*基本货币-黄少卿, 所有货币基本值都必须使用 uint32*/
class SUserCoin : public wd::CSeq
{
public:
    uint32 money;    //游戏内第一交易货币
    uint32 gold;    //充值货币, 主要用作交易
    uint32 ticket;    //一般用作充值货币的代替品, 不允许交易
    uint32 water;    //圣水
    uint32 star;    //星星
    uint32 active_score;    //活跃值
    uint32 medal;    //勋章
    uint32 tomb;    //墓地
    uint32 guild_contribute;    //公会贡献度
    uint32 day_task_val;    //日常任务积分

    SUserCoin() : money(0), gold(0), ticket(0), water(0), star(0), active_score(0), medal(0), tomb(0), guild_contribute(0), day_task_val(0)
    {
    }

    virtual ~SUserCoin()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserCoin(*this) );
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
            && TFVarTypeProcess( money, eType, stream, uiSize )
            && TFVarTypeProcess( gold, eType, stream, uiSize )
            && TFVarTypeProcess( ticket, eType, stream, uiSize )
            && TFVarTypeProcess( water, eType, stream, uiSize )
            && TFVarTypeProcess( star, eType, stream, uiSize )
            && TFVarTypeProcess( active_score, eType, stream, uiSize )
            && TFVarTypeProcess( medal, eType, stream, uiSize )
            && TFVarTypeProcess( tomb, eType, stream, uiSize )
            && TFVarTypeProcess( guild_contribute, eType, stream, uiSize )
            && TFVarTypeProcess( day_task_val, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserCoin";
    }
};

#endif
