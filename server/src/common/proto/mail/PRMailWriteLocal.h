#ifndef _PRMailWriteLocal_H_
#define _PRMailWriteLocal_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/mail/SUserMail.h>

/*服务器内部中转协议*/
class PRMailWriteLocal : public SMsgHead
{
public:
    uint32 target_id;
    SUserMail data;

    PRMailWriteLocal() : target_id(0)
    {
        msg_cmd = 2126766481;
    }

    virtual ~PRMailWriteLocal()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMailWriteLocal(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMailWriteLocal";
    }
};

#endif
