#ifndef _PQTempleInfo_H_
#define _PQTempleInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 神殿信息*/
class PQTempleInfo : public SMsgHead
{
public:

    PQTempleInfo()
    {
        msg_cmd = 892087342;
    }

    virtual ~PQTempleInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTempleInfo(*this) );
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
        return "PQTempleInfo";
    }
};

#endif
