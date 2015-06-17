#ifndef _PQFightLoadRecord_H_
#define _PQFightLoadRecord_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQFightLoadRecord : public SMsgHead
{
public:

    PQFightLoadRecord()
    {
        msg_cmd = 210879371;
    }

    virtual ~PQFightLoadRecord()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightLoadRecord(*this) );
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
            && loopend( stream, type, uiSize );
    }
};

#endif
