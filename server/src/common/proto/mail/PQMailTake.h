#ifndef _PQMailTake_H_
#define _PQMailTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQMailTake : public SMsgHead
{
public:
    uint32 mail_id;    //mail id

    PQMailTake() : mail_id(0)
    {
        msg_cmd = 632569249;
    }

    virtual ~PQMailTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMailTake(*this) );
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
            && TFVarTypeProcess( mail_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMailTake";
    }
};

#endif
