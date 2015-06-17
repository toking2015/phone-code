#ifndef _PQSocialServerBind_H_
#define _PQSocialServerBind_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*服务器标识绑定*/
class PQSocialServerBind : public SMsgHead
{
public:
    uint32 sid;    //服务器标识号

    PQSocialServerBind() : sid(0)
    {
        msg_cmd = 941776562;
    }

    virtual ~PQSocialServerBind()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSocialServerBind(*this) );
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
            && TFVarTypeProcess( sid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSocialServerBind";
    }
};

#endif
