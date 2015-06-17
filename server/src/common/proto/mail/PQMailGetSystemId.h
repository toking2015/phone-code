#ifndef _PQMailGetSystemId_H_
#define _PQMailGetSystemId_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*==========================全服邮件用=========================*/
class PQMailGetSystemId : public SMsgHead
{
public:

    PQMailGetSystemId()
    {
        msg_cmd = 628964938;
    }

    virtual ~PQMailGetSystemId()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMailGetSystemId(*this) );
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
        return "PQMailGetSystemId";
    }
};

#endif
