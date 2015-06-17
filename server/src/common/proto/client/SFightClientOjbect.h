#ifndef _SFightClientOjbect_H_
#define _SFightClientOjbect_H_

#include <weedong/core/seq/seq.h>
class SFightClientOjbect : public wd::CSeq
{
public:
    uint32 startTime;
    uint32 endTime;
    uint32 pathTime;
    uint32 targetTime;
    uint32 ackTime;

    SFightClientOjbect() : startTime(0), endTime(0), pathTime(0), targetTime(0), ackTime(0)
    {
    }

    virtual ~SFightClientOjbect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightClientOjbect(*this) );
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
            && TFVarTypeProcess( startTime, eType, stream, uiSize )
            && TFVarTypeProcess( endTime, eType, stream, uiSize )
            && TFVarTypeProcess( pathTime, eType, stream, uiSize )
            && TFVarTypeProcess( targetTime, eType, stream, uiSize )
            && TFVarTypeProcess( ackTime, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightClientOjbect";
    }
};

#endif
