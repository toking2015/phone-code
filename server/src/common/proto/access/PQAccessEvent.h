#ifndef _PQAccessEvent_H_
#define _PQAccessEvent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*=========================通迅协议============================*/
class PQAccessEvent : public SMsgHead
{
public:
    int32 sock;
    uint32 code;

    PQAccessEvent() : sock(0), code(0)
    {
        msg_cmd = 1001173331;
    }

    virtual ~PQAccessEvent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQAccessEvent(*this) );
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
            && TFVarTypeProcess( sock, eType, stream, uiSize )
            && TFVarTypeProcess( code, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQAccessEvent";
    }
};

#endif
