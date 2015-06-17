#ifndef _PQVipTimeLimitShopWeek_H_
#define _PQVipTimeLimitShopWeek_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求商品列表*/
class PQVipTimeLimitShopWeek : public SMsgHead
{
public:

    PQVipTimeLimitShopWeek()
    {
        msg_cmd = 746990542;
    }

    virtual ~PQVipTimeLimitShopWeek()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQVipTimeLimitShopWeek(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQVipTimeLimitShopWeek";
    }
};

#endif
