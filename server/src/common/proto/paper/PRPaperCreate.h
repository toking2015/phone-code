#ifndef _PRPaperCreate_H_
#define _PRPaperCreate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRPaperCreate : public SMsgHead
{
public:
    uint32 paper_id;    //图纸id

    PRPaperCreate() : paper_id(0)
    {
        msg_cmd = 1861819907;
    }

    virtual ~PRPaperCreate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPaperCreate(*this) );
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
        return "PRPaperCreate";
    }
};

#endif
