#ifndef _PQSingleArenaClearCD_H_
#define _PQSingleArenaClearCD_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*清空挑战CD*/
class PQSingleArenaClearCD : public SMsgHead
{
public:

    PQSingleArenaClearCD()
    {
        msg_cmd = 2781945;
    }

    virtual ~PQSingleArenaClearCD()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleArenaClearCD(*this) );
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
        return "PQSingleArenaClearCD";
    }
};

#endif
