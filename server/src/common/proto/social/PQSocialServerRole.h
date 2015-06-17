#ifndef _PQSocialServerRole_H_
#define _PQSocialServerRole_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/social/SSocialRole.h>

/*角色信息*/
class PQSocialServerRole : public SMsgHead
{
public:
    SSocialRole role;

    PQSocialServerRole()
    {
        msg_cmd = 283687696;
    }

    virtual ~PQSocialServerRole()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSocialServerRole(*this) );
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
            && TFVarTypeProcess( role, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSocialServerRole";
    }
};

#endif
