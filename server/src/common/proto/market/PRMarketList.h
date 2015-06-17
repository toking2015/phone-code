#ifndef _PRMarketList_H_
#define _PRMarketList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/market/SMarketSellCargo.h>

class PRMarketList : public SMsgHead
{
public:
    std::vector< SMarketSellCargo > list;    //list 为空时为最后一个数据包

    PRMarketList()
    {
        msg_cmd = 1593277506;
    }

    virtual ~PRMarketList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMarketList(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMarketList";
    }
};

#endif
