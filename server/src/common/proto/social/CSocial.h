#ifndef _CSocial_H_
#define _CSocial_H_

#include <weedong/core/seq/seq.h>
#include <proto/social/SSocialRole.h>

class CSocial : public wd::CSeq
{
public:
    uint32 initialized;    //数据初始化标识, kTrue, kFlase
    std::map< uint32, uint32 > server_socket;
    std::map< uint32, uint32 > socket_server;
    uint32 last_recv_time;    //最后数据接收时间( gamesvr 用 )
    std::map< uint32, SSocialRole > user_map;

    CSocial() : initialized(0), last_recv_time(0)
    {
    }

    virtual ~CSocial()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CSocial(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( initialized, eType, stream, uiSize )
            && TFVarTypeProcess( server_socket, eType, stream, uiSize )
            && TFVarTypeProcess( socket_server, eType, stream, uiSize )
            && TFVarTypeProcess( last_recv_time, eType, stream, uiSize )
            && TFVarTypeProcess( user_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CSocial";
    }
};

#endif
