#ifndef _PQMarketSocialDownTimeout_H_
#define _PQMarketSocialDownTimeout_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQMarketSocialDownTimeout : public SMsgHead
{
public:
    uint32 sid;    //服务器id

    PQMarketSocialDownTimeout() : sid(0)
    {
        msg_cmd = 94466203;
    }

    virtual ~PQMarketSocialDownTimeout()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketSocialDownTimeout(*this) );
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
        return "PQMarketSocialDownTimeout";
    }
};

#endif
