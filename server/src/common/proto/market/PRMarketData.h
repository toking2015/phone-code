#ifndef _PRMarketData_H_
#define _PRMarketData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*返回拍卖行可交易信息*/
class PRMarketData : public SMsgHead
{
public:

    PRMarketData()
    {
        msg_cmd = 1902083786;
    }

    virtual ~PRMarketData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketData(*this) );
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
        return "PRMarketData";
    }
};

#endif
