#ifndef _PRTotemActivate_H_
#define _PRTotemActivate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTotemActivate : public SMsgHead
{
public:
    uint32 is_success;
    uint32 totem_id;

    PRTotemActivate() : is_success(0), totem_id(0)
    {
        msg_cmd = 1522640888;
    }

    virtual ~PRTotemActivate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTotemActivate(*this) );
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
            && TFVarTypeProcess( is_success, eType, stream, uiSize )
            && TFVarTypeProcess( totem_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTotemActivate";
    }
};

#endif
