#ifndef _PRSystemUserUpdateSession_H_
#define _PRSystemUserUpdateSession_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*更新用户session, auth->game, auth->access*/
class PRSystemUserUpdateSession : public SMsgHead
{
public:

    PRSystemUserUpdateSession()
    {
        msg_cmd = 1340090719;
    }

    virtual ~PRSystemUserUpdateSession()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemUserUpdateSession(*this) );
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
        return "PRSystemUserUpdateSession";
    }
};

#endif
