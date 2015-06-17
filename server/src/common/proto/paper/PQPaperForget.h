#ifndef _PQPaperForget_H_
#define _PQPaperForget_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@遗忘*/
class PQPaperForget : public SMsgHead
{
public:

    PQPaperForget()
    {
        msg_cmd = 125886294;
    }

    virtual ~PQPaperForget()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPaperForget(*this) );
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
        return "PQPaperForget";
    }
};

#endif
