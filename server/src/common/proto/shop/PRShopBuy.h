#ifndef _PRShopBuy_H_
#define _PRShopBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRShopBuy : public SMsgHead
{
public:
    int8 status;    //0:失败，1:成功
    uint32 id;    //商品id
    uint32 count;    //数量

    PRShopBuy() : status(0), id(0), count(0)
    {
        msg_cmd = 1696054534;
    }

    virtual ~PRShopBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRShopBuy(*this) );
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
            && TFVarTypeProcess( status, eType, stream, uiSize )
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRShopBuy";
    }
};

#endif
