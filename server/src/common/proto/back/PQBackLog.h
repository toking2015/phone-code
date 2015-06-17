#ifndef _PQBackLog_H_
#define _PQBackLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求日志记录*/
class PQBackLog : public SMsgHead
{
public:
    std::string log_title;
    std::string log_text;
    uint32 log_time;

    PQBackLog() : log_time(0)
    {
        msg_cmd = 883558710;
    }

    virtual ~PQBackLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBackLog(*this) );
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
            && TFVarTypeProcess( log_title, eType, stream, uiSize )
            && TFVarTypeProcess( log_text, eType, stream, uiSize )
            && TFVarTypeProcess( log_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBackLog";
    }
};

#endif
