#ifndef _PQFightGetRecord_H_
#define _PQFightGetRecord_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQFightGetRecord : public SMsgHead
{
public:
    uint32 guid;
    uint32 target_id;

    PQFightGetRecord() : guid(0), target_id(0)
    {
        msg_cmd = 724397166;
    }

    virtual ~PQFightGetRecord()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightGetRecord(*this) );
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
            && TFVarTypeProcess( guid, type, stream, uiSize )
            && TFVarTypeProcess( target_id, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

#endif
