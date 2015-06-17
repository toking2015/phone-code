#ifndef _PQSingleArenaAddTimes_H_
#define _PQSingleArenaAddTimes_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*增加挑战次数*/
class PQSingleArenaAddTimes : public SMsgHead
{
public:

    PQSingleArenaAddTimes()
    {
        msg_cmd = 461113896;
    }

    virtual ~PQSingleArenaAddTimes()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleArenaAddTimes(*this) );
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
        return "PQSingleArenaAddTimes";
    }
};

#endif
