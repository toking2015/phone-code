#ifndef _PQMarketData_H_
#define _PQMarketData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求当前拍卖行可交易信息*/
class PQMarketData : public SMsgHead
{
public:

    PQMarketData()
    {
        msg_cmd = 785282277;
    }

    virtual ~PQMarketData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketData(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketData";
    }
};

#endif
