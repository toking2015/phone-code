#ifndef _PQItemRedeem_H_
#define _PQItemRedeem_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@物品赎回*/
class PQItemRedeem : public SMsgHead
{
public:
    uint32 guid;    //赎回id

    PQItemRedeem() : guid(0)
    {
        msg_cmd = 88915416;
    }

    virtual ~PQItemRedeem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQItemRedeem(*this) );
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
        return "PQItemRedeem";
    }
};

#endif
