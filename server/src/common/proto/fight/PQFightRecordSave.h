#ifndef _PQFightRecordSave_H_
#define _PQFightRecordSave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightRecord.h>

/*保存战斗LOG*/
class PQFightRecordSave : public SMsgHead
{
public:
    SFightRecord fight_record;

    PQFightRecordSave()
    {
        msg_cmd = 409725311;
    }

    virtual ~PQFightRecordSave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightRecordSave(*this) );
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
        return "PQFightRecordSave";
    }
};

#endif
