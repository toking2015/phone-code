#ifndef _PRShopMysteryGoods_H_
#define _PRShopMysteryGoods_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/shop/SUserMysteryGoods.h>

/*神秘商店商品列表*/
class PRShopMysteryGoods : public SMsgHead
{
public:
    std::vector< SUserMysteryGoods > goods_list;

    PRShopMysteryGoods()
    {
        msg_cmd = 2075346742;
    }

    virtual ~PRShopMysteryGoods()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRShopMysteryGoods(*this) );
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
            && TFVarTypeProcess( goods_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRShopMysteryGoods";
    }
};

#endif
