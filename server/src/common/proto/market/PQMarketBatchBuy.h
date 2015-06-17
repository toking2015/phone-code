#ifndef _PQMarketBatchBuy_H_
#define _PQMarketBatchBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketMatch.h>

/*批量货物购买*/
class PQMarketBatchBuy : public SMsgHead
{
public:
    uint32 sid;    //服务器标识(仅服务器处理)
    std::vector< SMarketMatch > cargos;    //购物信息
    uint32 value;    //预扣除货币值
    uint32 path;    //由客户端传递, 0 为使用默认值

    PQMarketBatchBuy() : sid(0), value(0), path(0)
    {
        msg_cmd = 214967243;
    }

    virtual ~PQMarketBatchBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketBatchBuy(*this) );
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
            && TFVarTypeProcess( sid, eType, stream, uiSize )
            && TFVarTypeProcess( cargos, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && TFVarTypeProcess( path, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketBatchBuy";
    }
};

#endif
