#ifndef _PQSystemKick_H_
#define _PQSystemKick_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*踢人*/
class PQSystemKick : public SMsgHead
{
public:

    PQSystemKick()
    {
        msg_cmd = 14859210;
    }

    virtual ~PQSystemKick()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSystemKick(*this) );
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
        return "PQSystemKick";
    }
};

#endif
