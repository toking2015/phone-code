#ifndef _PRTotemAccelerate_H_
#define _PRTotemAccelerate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/totem/STotem.h>

class PRTotemAccelerate : public SMsgHead
{
public:
    STotem totem;

    PRTotemAccelerate()
    {
        msg_cmd = 1616213530;
    }

    virtual ~PRTotemAccelerate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTotemAccelerate(*this) );
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
            && TFVarTypeProcess( totem, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTotemAccelerate";
    }
};

#endif
