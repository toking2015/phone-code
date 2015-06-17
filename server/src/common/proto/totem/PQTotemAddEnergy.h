#ifndef _PQTotemAddEnergy_H_
#define _PQTotemAddEnergy_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 充能*/
class PQTotemAddEnergy : public SMsgHead
{
public:
    uint32 totem_guid;

    PQTotemAddEnergy() : totem_guid(0)
    {
        msg_cmd = 624722301;
    }

    virtual ~PQTotemAddEnergy()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTotemAddEnergy(*this) );
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
            && TFVarTypeProcess( totem_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTotemAddEnergy";
    }
};

#endif
