#ifndef _PQTotemBless_H_
#define _PQTotemBless_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 技能祝福*/
class PQTotemBless : public SMsgHead
{
public:
    uint32 totem_guid;
    uint32 skill_type;    // kTotemSkillTypeXXX

    PQTotemBless() : totem_guid(0), skill_type(0)
    {
        msg_cmd = 402450518;
    }

    virtual ~PQTotemBless()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTotemBless(*this) );
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
            && TFVarTypeProcess( skill_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTotemBless";
    }
};

#endif
