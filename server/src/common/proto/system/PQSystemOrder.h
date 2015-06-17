#ifndef _PQSystemOrder_H_
#define _PQSystemOrder_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*协议包序列同步*/
class PQSystemOrder : public SMsgHead
{
public:

    PQSystemOrder()
    {
        msg_cmd = 123883356;
    }

    virtual ~PQSystemOrder()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSystemOrder(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSystemOrder";
    }
};

#endif
