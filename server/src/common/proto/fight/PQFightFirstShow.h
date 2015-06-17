#ifndef _PQFightFirstShow_H_
#define _PQFightFirstShow_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*首场开场动画*/
class PQFightFirstShow : public SMsgHead
{
public:

    PQFightFirstShow()
    {
        msg_cmd = 317670076;
    }

    virtual ~PQFightFirstShow()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightFirstShow(*this) );
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
        return "PQFightFirstShow";
    }
};

#endif
