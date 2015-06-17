#ifndef _PQMarketLogData_H_
#define _PQMarketLogData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketLog.h>

class PQMarketLogData : public SMsgHead
{
public:
    SMarketLog data;

    PQMarketLogData()
    {
        msg_cmd = 87357617;
    }

    virtual ~PQMarketLogData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketLogData(*this) );
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
            && TFVarTypeProcess( data, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketLogData";
    }
};

#endif
