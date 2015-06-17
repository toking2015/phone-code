#ifndef _PQSystemOnline_H_
#define _PQSystemOnline_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*客户端每10分钟发送一次, 服务器30分钟超时作为离线判断*/
class PQSystemOnline : public SMsgHead
{
public:

    PQSystemOnline()
    {
        msg_cmd = 374822355;
    }

    virtual ~PQSystemOnline()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSystemOnline(*this) );
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
        return "PQSystemOnline";
    }
};

#endif
