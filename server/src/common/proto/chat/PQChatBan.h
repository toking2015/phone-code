#ifndef _PQChatBan_H_
#define _PQChatBan_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQChatBan : public SMsgHead
{
public:
    uint32 end_time;    //结束时间

    PQChatBan() : end_time(0)
    {
        msg_cmd = 511928501;
    }

    virtual ~PQChatBan()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQChatBan(*this) );
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
            && TFVarTypeProcess( end_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQChatBan";
    }
};

#endif
