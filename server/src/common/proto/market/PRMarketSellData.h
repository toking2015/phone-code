#ifndef _PRMarketSellData_H_
#define _PRMarketSellData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketSellCargo.h>

class PRMarketSellData : public SMsgHead
{
public:
    uint8 set_type;    //kObjectAdd, kObjectUpdate, kObjectDel
    SMarketSellCargo data;

    PRMarketSellData() : set_type(0)
    {
        msg_cmd = 1824851074;
    }

    virtual ~PRMarketSellData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketSellData(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketSellData";
    }
};

#endif
