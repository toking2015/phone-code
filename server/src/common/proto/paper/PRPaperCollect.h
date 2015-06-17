#ifndef _PRPaperCollect_H_
#define _PRPaperCollect_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*采集成功*/
class PRPaperCollect : public SMsgHead
{
public:
    uint32 item_id;
    uint32 num;

    PRPaperCollect() : item_id(0), num(0)
    {
        msg_cmd = 1843830073;
    }

    virtual ~PRPaperCollect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPaperCollect(*this) );
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
            && TFVarTypeProcess( item_id, eType, stream, uiSize )
            && TFVarTypeProcess( num, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPaperCollect";
    }
};

#endif
