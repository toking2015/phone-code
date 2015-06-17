#ifndef _PRFightRecordGet_H_
#define _PRFightRecordGet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightRecord.h>

class PRFightRecordGet : public SMsgHead
{
public:
    SFightRecord fight_record;

    PRFightRecordGet()
    {
        msg_cmd = 1176844493;
    }

    virtual ~PRFightRecordGet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightRecordGet(*this) );
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
            && TFVarTypeProcess( fight_record, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFightRecordGet";
    }
};

#endif
