#ifndef _PQMarketSocialReset_H_
#define _PQMarketSocialReset_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQMarketSocialReset : public SMsgHead
{
public:
    uint32 sid;    //将指定服的购买索引转移到跨服索引(sid = 0)

    PQMarketSocialReset() : sid(0)
    {
        msg_cmd = 131107855;
    }

    virtual ~PQMarketSocialReset()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketSocialReset(*this) );
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
        return "PQMarketSocialReset";
    }
};

#endif
