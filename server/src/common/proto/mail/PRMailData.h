#ifndef _PRMailData_H_
#define _PRMailData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/mail/SUserMail.h>

class PRMailData : public SMsgHead
{
public:
    uint32 set_type;    //[ kObjectAdd, kObjectUpdate, kObjectDel ]
    SUserMail data;

    PRMailData() : set_type(0)
    {
        msg_cmd = 1094044067;
    }

    virtual ~PRMailData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMailData(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMailData";
    }
};

#endif
