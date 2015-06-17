#ifndef _PRFightGetRecord_H_
#define _PRFightGetRecord_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightRecord.h>

class PRFightGetRecord : public SMsgHead
{
public:
    SFightRecord fight_record;
    uint32 target_id;

    PRFightGetRecord() : target_id(0)
    {
        msg_cmd = 3396150699;
    }

    virtual ~PRFightGetRecord()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightGetRecord(*this) );
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
            && TFVarTypeProcess( target_id, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

#endif
