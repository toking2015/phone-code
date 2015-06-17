#ifndef _PQVipLevelUp_H_
#define _PQVipLevelUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求升级*/
class PQVipLevelUp : public SMsgHead
{
public:

    PQVipLevelUp()
    {
        msg_cmd = 599266307;
    }

    virtual ~PQVipLevelUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQVipLevelUp(*this) );
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
        return "PQVipLevelUp";
    }
};

#endif
