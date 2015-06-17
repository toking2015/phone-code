#ifndef _PRMarketAllList_H_
#define _PRMarketAllList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketSellCargo.h>

class PRMarketAllList : public SMsgHead
{
public:
    std::vector< SMarketSellCargo > data;    //分包返回, data 为空时为最后一个包

    PRMarketAllList()
    {
        msg_cmd = 1363111447;
    }

    virtual ~PRMarketAllList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketAllList(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketAllList";
    }
};

#endif
