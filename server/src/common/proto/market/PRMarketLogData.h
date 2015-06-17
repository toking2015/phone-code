#ifndef _PRMarketLogData_H_
#define _PRMarketLogData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketLog.h>

/*返回单条日志( 卖品售出后 )*/
class PRMarketLogData : public SMsgHead
{
public:
    SMarketLog data;

    PRMarketLogData()
    {
        msg_cmd = 2026116139;
    }

    virtual ~PRMarketLogData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketLogData(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketLogData";
    }
};

#endif
