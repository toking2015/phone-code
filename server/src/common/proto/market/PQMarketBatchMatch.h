#ifndef _PQMarketBatchMatch_H_
#define _PQMarketBatchMatch_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*批量获取购买数据*/
class PQMarketBatchMatch : public SMsgHead
{
public:
    uint32 sid;    //服务器标识(仅服务器处理)
    std::vector< S3UInt32 > coins;    //批量匹配列表

    PQMarketBatchMatch() : sid(0)
    {
        msg_cmd = 382628001;
    }

    virtual ~PQMarketBatchMatch()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketBatchMatch(*this) );
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
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketBatchMatch";
    }
};

#endif
