#ifndef _SUserPay_H_
#define _SUserPay_H_

#include <weedong/core/seq/seq.h>
/*基本支付-印佳, 所有货币基本值都必须使用 uint32*/
class SUserPay : public wd::CSeq
{
public:
    uint32 uid;    //唯一id
    uint32 price;    //充值金额(RMB), 价值 != 钻石
    uint32 time;    //充值日期
    uint8 type;    //充值类型 [ kPayTypeNormal | kPayTypeSpecial ]
    uint8 flag;    //标记kPayFlagTake

    SUserPay() : uid(0), price(0), time(0), type(0), flag(0)
    {
    }

    virtual ~SUserPay()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserPay(*this) );
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
            && TFVarTypeProcess( uid, eType, stream, uiSize )
            && TFVarTypeProcess( price, eType, stream, uiSize )
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserPay";
    }
};

#endif
