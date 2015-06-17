#ifndef _PRVipTimeLimitShopBuy_H_
#define _PRVipTimeLimitShopBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/viptimelimitshop/SUserVipTimeLimitGoods.h>

/*@@返回购买记录*/
class PRVipTimeLimitShopBuy : public SMsgHead
{
public:
    SUserVipTimeLimitGoods buyed_info;    //购买记录单个
    uint8 set_type;    //kObjectAdd, kObjectUpdate, kObjectDel

    PRVipTimeLimitShopBuy() : set_type(0)
    {
        msg_cmd = 1101010730;
    }

    virtual ~PRVipTimeLimitShopBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRVipTimeLimitShopBuy(*this) );
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
            && TFVarTypeProcess( buyed_info, eType, stream, uiSize )
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRVipTimeLimitShopBuy";
    }
};

#endif
