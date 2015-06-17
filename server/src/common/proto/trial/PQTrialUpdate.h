#ifndef _PQTrialUpdate_H_
#define _PQTrialUpdate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求更新*/
class PQTrialUpdate : public SMsgHead
{
public:

    PQTrialUpdate()
    {
        msg_cmd = 898503924;
    }

    virtual ~PQTrialUpdate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTrialUpdate(*this) );
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
        return "PQTrialUpdate";
    }
};

#endif
