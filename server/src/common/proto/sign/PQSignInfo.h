#ifndef _PQSignInfo_H_
#define _PQSignInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 签到信息*/
class PQSignInfo : public SMsgHead
{
public:

    PQSignInfo()
    {
        msg_cmd = 35064835;
    }

    virtual ~PQSignInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSignInfo(*this) );
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
        return "PQSignInfo";
    }
};

#endif
