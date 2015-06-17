#ifndef _PRMarketSell_H_
#define _PRMarketSell_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

class PRMarketSell : public SMsgHead
{
public:
    uint32 cargo_id;    //id
    std::string name;    //购买人名称
    uint32 value;    //交易金币量
    S3UInt32 coin;    //交易货品

    PRMarketSell() : cargo_id(0), value(0)
    {
        msg_cmd = 1795127888;
    }

    virtual ~PRMarketSell()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketSell(*this) );
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
            && TFVarTypeProcess( cargo_id, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketSell";
    }
};

#endif
