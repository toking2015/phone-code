#ifndef _PRTotemAddEnergy_H_
#define _PRTotemAddEnergy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/totem/STotem.h>

class PRTotemAddEnergy : public SMsgHead
{
public:
    STotem totem;

    PRTotemAddEnergy()
    {
        msg_cmd = 1996672069;
    }

    virtual ~PRTotemAddEnergy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTotemAddEnergy(*this) );
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
        return "PRTotemAddEnergy";
    }
};

#endif
