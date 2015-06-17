#ifndef _PROpenTargetBuy_H_
#define _PROpenTargetBuy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PROpenTargetBuy : public SMsgHead
{
public:
    uint32 day;
    uint32 guid;

    PROpenTargetBuy() : day(0), guid(0)
    {
        msg_cmd = 1092130525;
    }

    virtual ~PROpenTargetBuy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PROpenTargetBuy(*this) );
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
            && TFVarTypeProcess( day, eType, stream, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PROpenTargetBuy";
    }
};

#endif
