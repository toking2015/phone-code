#ifndef _PQFightRecordID_H_
#define _PQFightRecordID_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*战斗记录ID 服务端用的*/
class PQFightRecordID : public SMsgHead
{
public:

    PQFightRecordID()
    {
        msg_cmd = 37267773;
    }

    virtual ~PQFightRecordID()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightRecordID(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFightRecordID";
    }
};

#endif
