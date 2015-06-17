#ifndef _PQShopBuy_H_
#define _PQShopBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*购买*/
class PQShopBuy : public SMsgHead
{
public:
    uint32 id;    //商品id
    uint32 count;    //数量

    PQShopBuy() : id(0), count(0)
    {
        msg_cmd = 355460715;
    }

    virtual ~PQShopBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQShopBuy(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQShopBuy";
    }
};

#endif
