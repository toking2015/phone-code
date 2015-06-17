#ifndef _PRTotemBless_H_
#define _PRTotemBless_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/totem/STotem.h>

class PRTotemBless : public SMsgHead
{
public:
    STotem totem;

    PRTotemBless()
    {
        msg_cmd = 1929801727;
    }

    virtual ~PRTotemBless()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTotemBless(*this) );
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
        return "PRTotemBless";
    }
};

#endif
