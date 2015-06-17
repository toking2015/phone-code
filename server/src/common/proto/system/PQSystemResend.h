#ifndef _PQSystemResend_H_
#define _PQSystemResend_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*客户端请求数据包重发*/
class PQSystemResend : public SMsgHead
{
public:
    uint32 server_order;    //重发起始 order

    PQSystemResend() : server_order(0)
    {
        msg_cmd = 513134002;
    }

    virtual ~PQSystemResend()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSystemResend(*this) );
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
            && TFVarTypeProcess( server_order, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSystemResend";
    }
};

#endif
