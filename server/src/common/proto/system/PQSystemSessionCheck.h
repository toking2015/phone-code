#ifndef _PQSystemSessionCheck_H_
#define _PQSystemSessionCheck_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*测试有效连接( 用于网络重连后检查 )*/
class PQSystemSessionCheck : public SMsgHead
{
public:

    PQSystemSessionCheck()
    {
        msg_cmd = 788199199;
    }

    virtual ~PQSystemSessionCheck()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSystemSessionCheck(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSystemSessionCheck";
    }
};

#endif
