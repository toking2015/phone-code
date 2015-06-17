#ifndef _PRMailSave_H_
#define _PRMailSave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRMailSave : public SMsgHead
{
public:
    uint32 mail_id;

    PRMailSave() : mail_id(0)
    {
        msg_cmd = 1994869338;
    }

    virtual ~PRMailSave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMailSave(*this) );
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
        return "PRMailSave";
    }
};

#endif
