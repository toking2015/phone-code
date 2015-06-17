#ifndef _PQMailReaded_H_
#define _PQMailReaded_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*修改阅读协议*/
class PQMailReaded : public SMsgHead
{
public:
    uint32 mail_id;

    PQMailReaded() : mail_id(0)
    {
        msg_cmd = 155252786;
    }

    virtual ~PQMailReaded()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMailReaded(*this) );
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
        return "PQMailReaded";
    }
};

#endif
