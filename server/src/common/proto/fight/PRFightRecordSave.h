#ifndef _PRFightRecordSave_H_
#define _PRFightRecordSave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightRecord.h>

class PRFightRecordSave : public SMsgHead
{
public:
    SFightRecord fight_record;

    PRFightRecordSave()
    {
        msg_cmd = 1286366374;
    }

    virtual ~PRFightRecordSave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightRecordSave(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( fight_record, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

#endif
