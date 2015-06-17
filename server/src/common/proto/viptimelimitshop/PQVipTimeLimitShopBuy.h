#ifndef _PQVipTimeLimitShopBuy_H_
#define _PQVipTimeLimitShopBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求购买*/
class PQVipTimeLimitShopBuy : public SMsgHead
{
public:
    uint32 vip_level;    //购买礼包的等级
    uint32 count;    //购买数量

    PQVipTimeLimitShopBuy() : vip_level(0), count(0)
    {
        msg_cmd = 1936613;
    }

    virtual ~PQVipTimeLimitShopBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQVipTimeLimitShopBuy(*this) );
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
            && TFVarTypeProcess( vip_level, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQVipTimeLimitShopBuy";
    }
};

#endif
