#ifndef _PQMarketBuyData_H_
#define _PQMarketBuyData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@刷新单个买方货物数据*/
class PQMarketBuyData : public SMsgHead
{
public:
    uint32 guid;

    PQMarketBuyData() : guid(0)
    {
        msg_cmd = 1045086949;
    }

    virtual ~PQMarketBuyData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketBuyData(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketBuyData";
    }
};

#endif
