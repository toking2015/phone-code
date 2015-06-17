#ifndef _SFightRecordSimple_H_
#define _SFightRecordSimple_H_

#include <weedong/core/seq/seq.h>
class SFightRecordSimple : public wd::CSeq
{
public:
    uint32 guid;
    uint32 create_time;

    SFightRecordSimple() : guid(0), create_time(0)
    {
    }

    virtual ~SFightRecordSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightRecordSimple(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( create_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightRecordSimple";
    }
};

#endif
