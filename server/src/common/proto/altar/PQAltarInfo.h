#ifndef _PQAltarInfo_H_
#define _PQAltarInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*=========================通迅协议============================*/
class PQAltarInfo : public SMsgHead
{
public:

    PQAltarInfo()
    {
        msg_cmd = 11246124;
    }

    virtual ~PQAltarInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQAltarInfo(*this) );
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
        return "PQAltarInfo";
    }
};

#endif
