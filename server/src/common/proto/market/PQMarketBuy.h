#ifndef _PQMarketBuy_H_
#define _PQMarketBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*购买货物*/
class PQMarketBuy : public SMsgHead
{
public:
    uint32 guid;    //用户内唯一 SUserCargo guid
    uint32 count;    //购买数量
    uint32 value;    //guid != 0 为需要花费的金币, 由客户端计算服务器验证, guid = 0 为 购买的 item_id
    uint8 percent;    //客户端物价, 服务器对校物价是否存在变动, 变动会导致购买失败

    PQMarketBuy() : guid(0), count(0), value(0), percent(0)
    {
        msg_cmd = 350735340;
    }

    virtual ~PQMarketBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketBuy(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketBuy";
    }
};

#endif
