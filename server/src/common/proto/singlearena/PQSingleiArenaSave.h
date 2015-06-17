#ifndef _PQSingleiArenaSave_H_
#define _PQSingleiArenaSave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/singlearena/SSingleArenaOpponent.h>

/*==============================服务器用========================*/
class PQSingleiArenaSave : public SMsgHead
{
public:
    SSingleArenaOpponent data;

    PQSingleiArenaSave()
    {
        msg_cmd = 688888339;
    }

    virtual ~PQSingleiArenaSave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleiArenaSave(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( data, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PQSingleiArenaSave";
    }
};

#endif
