#ifndef _PQTotemAccelerate_H_
#define _PQTotemAccelerate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 充能加速*/
class PQTotemAccelerate : public SMsgHead
{
public:
    uint32 totem_guid;
    uint32 is_free;    // 0-花钱，1-免费

    PQTotemAccelerate() : totem_guid(0), is_free(0)
    {
        msg_cmd = 261979214;
    }

    virtual ~PQTotemAccelerate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTotemAccelerate(*this) );
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
            && TFVarTypeProcess( totem_guid, eType, stream, uiSize )
            && TFVarTypeProcess( is_free, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTotemAccelerate";
    }
};

#endif
