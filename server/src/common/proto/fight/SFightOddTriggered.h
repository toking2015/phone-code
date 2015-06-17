#ifndef _SFightOddTriggered_H_
#define _SFightOddTriggered_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightSoldierSimple.h>

class SFightOddTriggered : public wd::CSeq
{
public:
    uint32 use_guid;    //触发者ID
    uint32 odd_id;    //触发的ID
    std::vector< SFightSoldierSimple > targetList;    //目标方

    SFightOddTriggered() : use_guid(0), odd_id(0)
    {
    }

    virtual ~SFightOddTriggered()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightOddTriggered(*this) );
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
            && TFVarTypeProcess( use_guid, eType, stream, uiSize )
            && TFVarTypeProcess( odd_id, eType, stream, uiSize )
            && TFVarTypeProcess( targetList, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightOddTriggered";
    }
};

#endif
