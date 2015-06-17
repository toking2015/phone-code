#ifndef _PRSystemPing_H_
#define _PRSystemPing_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSystemPing : public SMsgHead
{
public:
    uint32 server_time;    //服务器时间

    PRSystemPing() : server_time(0)
    {
        msg_cmd = 1271524422;
    }

    virtual ~PRSystemPing()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemPing(*this) );
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
            && TFVarTypeProcess( server_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSystemPing";
    }
};

#endif
