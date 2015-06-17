#ifndef _PQPaperCreate_H_
#define _PQPaperCreate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@制作图纸*/
class PQPaperCreate : public SMsgHead
{
public:
    uint32 paper_id;    //图纸id

    PQPaperCreate() : paper_id(0)
    {
        msg_cmd = 795415437;
    }

    virtual ~PQPaperCreate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPaperCreate(*this) );
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
            && TFVarTypeProcess( paper_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPaperCreate";
    }
};

#endif
