#ifndef _PQTotemActivate_H_
#define _PQTotemActivate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 图腾激活*/
class PQTotemActivate : public SMsgHead
{
public:
    uint32 totem_id;    // 需要激活的图腾id

    PQTotemActivate() : totem_id(0)
    {
        msg_cmd = 936233025;
    }

    virtual ~PQTotemActivate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTotemActivate(*this) );
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
            && TFVarTypeProcess( totem_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTotemActivate";
    }
};

#endif
