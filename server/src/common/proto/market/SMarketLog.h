#ifndef _SMarketLog_H_
#define _SMarketLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*购买记录*/
class SMarketLog : public wd::CSeq
{
public:
    std::string name;    //购买方角色名
    S3UInt32 coin;    //购买物品
    uint32 time;    //购买时间
    uint32 price;    //购买总价, 卖方收益为 price * 0.9, 税收为 price * 0.1

    SMarketLog() : time(0), price(0)
    {
    }

    virtual ~SMarketLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMarketLog(*this) );
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
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && TFVarTypeProcess( price, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMarketLog";
    }
};

#endif
