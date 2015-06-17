#ifndef _PQFightRecordGet_H_
#define _PQFightRecordGet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*获取战斗LOG*/
class PQFightRecordGet : public SMsgHead
{
public:
    uint32 guid;

    PQFightRecordGet() : guid(0)
    {
        msg_cmd = 1025528566;
    }

    virtual ~PQFightRecordGet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightRecordGet(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFightRecordGet";
    }
};

#endif
