#ifndef _PRSystemLogin_H_
#define _PRSystemLogin_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSystemLogin : public SMsgHead
{
public:
    uint32 open_time;    // 开服时间
    uint32 server_time;    //服务器时间
    int32 minuteswest;
    int32 dsttime;
    int32 outside_sock;    //客户端连接号(服务器中转用)

    PRSystemLogin() : open_time(0), server_time(0), minuteswest(0), dsttime(0), outside_sock(0)
    {
        msg_cmd = 2063899790;
    }

    virtual ~PRSystemLogin()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemLogin(*this) );
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
            && TFVarTypeProcess( open_time, eType, stream, uiSize )
            && TFVarTypeProcess( server_time, eType, stream, uiSize )
            && TFVarTypeProcess( minuteswest, eType, stream, uiSize )
            && TFVarTypeProcess( dsttime, eType, stream, uiSize )
            && TFVarTypeProcess( outside_sock, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSystemLogin";
    }
};

#endif
