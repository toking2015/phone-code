#ifndef _PQMarketBuyAll_H_
#define _PQMarketBuyAll_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*购买全部货物*/
class PQMarketBuyAll : public SMsgHead
{
public:
    std::vector< S3UInt32 > coins;    //批量购买列表      cate->guid用户内唯一, objid->count购买数量, val->value需要花费的金币
    uint8 percent;    //客户端物价, 服务器对校物价是否存在变动, 变动会导致购买失败
    uint32 value;    //总的价值

    PQMarketBuyAll() : percent(0), value(0)
    {
        msg_cmd = 344619840;
    }

    virtual ~PQMarketBuyAll()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketBuyAll(*this) );
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
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketBuyAll";
    }
};

#endif
