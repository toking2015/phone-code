#ifndef _SMarketMatch_H_
#define _SMarketMatch_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*批量匹配信息*/
class SMarketMatch : public wd::CSeq
{
public:
    uint32 cargo_id;    //商品唯一ID
    S3UInt32 coin;    //需要购买量
    uint8 percent;    //上架货物价值比值[ 80 - 180 ], 默认值 100

    SMarketMatch() : cargo_id(0), percent(0)
    {
    }

    virtual ~SMarketMatch()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMarketMatch(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( cargo_id, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMarketMatch";
    }
};

#endif
