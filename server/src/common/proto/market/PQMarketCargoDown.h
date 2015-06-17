#ifndef _PQMarketCargoDown_H_
#define _PQMarketCargoDown_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求下架货物*/
class PQMarketCargoDown : public SMsgHead
{
public:
    uint32 cargo_id;    //需下架的货物id

    PQMarketCargoDown() : cargo_id(0)
    {
        msg_cmd = 107099549;
    }

    virtual ~PQMarketCargoDown()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketCargoDown(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketCargoDown";
    }
};

#endif
