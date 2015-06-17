#ifndef _PQSoldierRecruit_H_
#define _PQSoldierRecruit_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@武将招募*/
class PQSoldierRecruit : public SMsgHead
{
public:
    uint32 id;    //招募ID

    PQSoldierRecruit() : id(0)
    {
        msg_cmd = 47531286;
    }

    virtual ~PQSoldierRecruit()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierRecruit(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierRecruit";
    }
};

#endif
