#ifndef _PROpenTargetTake_H_
#define _PROpenTargetTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PROpenTargetTake : public SMsgHead
{
public:
    uint32 day;
    uint32 guid;

    PROpenTargetTake() : day(0), guid(0)
    {
        msg_cmd = 1126082129;
    }

    virtual ~PROpenTargetTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PROpenTargetTake(*this) );
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
        return "PROpenTargetTake";
    }
};

#endif
