#ifndef _PQTimerEvent_H_
#define _PQTimerEvent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*定时器事件--黄少卿*/
class PQTimerEvent : public SMsgHead
{
public:
    uint32 time_id;
    std::string time_key;
    std::string time_param;
    uint32 time_sec;

    PQTimerEvent() : time_id(0), time_sec(0)
    {
        msg_cmd = 113037829;
    }

    virtual ~PQTimerEvent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTimerEvent(*this) );
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
            && TFVarTypeProcess( time_id, eType, stream, uiSize )
            && TFVarTypeProcess( time_key, eType, stream, uiSize )
            && TFVarTypeProcess( time_param, eType, stream, uiSize )
            && TFVarTypeProcess( time_sec, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTimerEvent";
    }
};

#endif
