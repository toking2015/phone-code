#ifndef _SFightClientTotemSkill_H_
#define _SFightClientTotemSkill_H_

#include <weedong/core/seq/seq.h>
class SFightClientTotemSkill : public wd::CSeq
{
public:
    uint32 time;
    uint32 guid;

    SFightClientTotemSkill() : time(0), guid(0)
    {
    }

    virtual ~SFightClientTotemSkill()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightClientTotemSkill(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightClientTotemSkill";
    }
};

#endif
