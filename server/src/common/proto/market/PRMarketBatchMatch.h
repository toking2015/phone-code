#ifndef _PRMarketBatchMatch_H_
#define _PRMarketBatchMatch_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketMatch.h>

class PRMarketBatchMatch : public SMsgHead
{
public:
    uint32 result;    //0 为购买成功, 非 0 为对应错误码
    uint32 sid;    //服务器标识(仅服务器处理)
    std::vector< SMarketMatch > cargos;    //预购物信息

    PRMarketBatchMatch() : result(0), sid(0)
    {
        msg_cmd = 1229779097;
    }

    virtual ~PRMarketBatchMatch()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketBatchMatch(*this) );
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
            && TFVarTypeProcess( sid, eType, stream, uiSize )
            && TFVarTypeProcess( cargos, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketBatchMatch";
    }
};

#endif
