#ifndef _PRMailGetSystemId_H_
#define _PRMailGetSystemId_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRMailGetSystemId : public SMsgHead
{
public:
    uint32 system_mail_id;

    PRMailGetSystemId() : system_mail_id(0)
    {
        msg_cmd = 1243053845;
    }

    virtual ~PRMailGetSystemId()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMailGetSystemId(*this) );
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
            && TFVarTypeProcess( system_mail_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMailGetSystemId";
    }
};

#endif
