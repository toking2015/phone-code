#ifndef _PQMarketSellList_H_
#define _PQMarketSellList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求卖方列表*/
class PQMarketSellList : public SMsgHead
{
public:
    uint32 sid;    //服务器标识(仅服务器处理)

    PQMarketSellList() : sid(0)
    {
        msg_cmd = 1030132927;
    }

    virtual ~PQMarketSellList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketSellList(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketSellList";
    }
};

#endif
