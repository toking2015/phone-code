#ifndef _PQMarketDownTimeout_H_
#define _PQMarketDownTimeout_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQMarketDownTimeout : public SMsgHead
{
public:
    uint32 sid;    //服务器id

    PQMarketDownTimeout() : sid(0)
    {
        msg_cmd = 338435276;
    }

    virtual ~PQMarketDownTimeout()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketDownTimeout(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketDownTimeout";
    }
};

#endif
