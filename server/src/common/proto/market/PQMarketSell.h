#ifndef _PQMarketSell_H_
#define _PQMarketSell_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求售出金钱*/
class PQMarketSell : public SMsgHead
{
public:
    uint32 cargo_id;    //id

    PQMarketSell() : cargo_id(0)
    {
        msg_cmd = 402301576;
    }

    virtual ~PQMarketSell()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketSell(*this) );
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
            && TFVarTypeProcess( cargo_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketSell";
    }
};

#endif
