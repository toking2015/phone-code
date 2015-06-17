#ifndef _PRMarketBuy_H_
#define _PRMarketBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

class PRMarketBuy : public SMsgHead
{
public:
    uint32 result;    //0 为购买成功, 非 0 为对应错误码
    uint32 value;    //花费的金币
    S3UInt32 coin;    //购买成功获得货币

    PRMarketBuy() : result(0), value(0)
    {
        msg_cmd = 1339903691;
    }

    virtual ~PRMarketBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketBuy(*this) );
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
            && TFVarTypeProcess( result, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketBuy";
    }
};

#endif
