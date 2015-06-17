#ifndef _PRMailDataList_H_
#define _PRMailDataList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/mail/SUserMail.h>

class PRMailDataList : public SMsgHead
{
public:
    uint32 set_type;    //[ kObjectAdd, kObjectUpdate, kObjectDel ]
    std::vector< SUserMail > list;

    PRMailDataList() : set_type(0)
    {
        msg_cmd = 1082870710;
    }

    virtual ~PRMailDataList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRMailDataList(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRMailDataList";
    }
};

#endif
