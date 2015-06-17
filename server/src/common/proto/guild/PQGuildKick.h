#ifndef _PQGuildKick_H_
#define _PQGuildKick_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*踢人*/
class PQGuildKick : public SMsgHead
{
public:
    uint32 target_id;

    PQGuildKick() : target_id(0)
    {
        msg_cmd = 271473681;
    }

    virtual ~PQGuildKick()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGuildKick(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQGuildKick";
    }
};

#endif
