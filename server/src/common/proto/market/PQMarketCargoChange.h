#ifndef _PQMarketCargoChange_H_
#define _PQMarketCargoChange_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*交易口价格修改*/
class PQMarketCargoChange : public SMsgHead
{
public:
    uint32 cargo_id;
    uint8 percent;    //物价值修改[ 80 - 180 ]

    PQMarketCargoChange() : cargo_id(0), percent(0)
    {
        msg_cmd = 921604485;
    }

    virtual ~PQMarketCargoChange()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketCargoChange(*this) );
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
            && TFVarTypeProcess( percent, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketCargoChange";
    }
};

#endif
