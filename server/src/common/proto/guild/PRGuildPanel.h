#ifndef _PRGuildPanel_H_
#define _PRGuildPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/guild/SGuildPanel.h>

class PRGuildPanel : public SMsgHead
{
public:
    SGuildPanel data;

    PRGuildPanel()
    {
        msg_cmd = 1350056808;
    }

    virtual ~PRGuildPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildPanel(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildPanel";
    }
};

#endif
