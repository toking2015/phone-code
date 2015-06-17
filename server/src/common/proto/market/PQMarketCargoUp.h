#ifndef _PQMarketCargoUp_H_
#define _PQMarketCargoUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*请求上架货物*/
class PQMarketCargoUp : public SMsgHead
{
public:
    uint32 sid;    //服务器标识(仅服务器处理)
    S3UInt32 coin;    //上架货品, 目前只接受[ kCoinItem( 可交易, 未绑定 ) ]
    uint8 percent;    //上架货物价值比值[ 80 - 180 ], 默认值 100

    PQMarketCargoUp() : sid(0), percent(0)
    {
        msg_cmd = 761321872;
    }

    virtual ~PQMarketCargoUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketCargoUp(*this) );
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
            && TFVarTypeProcess( sid, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketCargoUp";
    }
};

#endif
