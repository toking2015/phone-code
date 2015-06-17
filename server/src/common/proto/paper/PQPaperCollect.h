#ifndef _PQPaperCollect_H_
#define _PQPaperCollect_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@采集*/
class PQPaperCollect : public SMsgHead
{
public:
    uint32 collect_level;    //资源点等级

    PQPaperCollect() : collect_level(0)
    {
        msg_cmd = 893714413;
    }

    virtual ~PQPaperCollect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPaperCollect(*this) );
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
            && TFVarTypeProcess( collect_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPaperCollect";
    }
};

#endif
