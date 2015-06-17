#ifndef _PRUserSimple_H_
#define _PRUserSimple_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/user/SUserSimple.h>

class PRUserSimple : public SMsgHead
{
public:
    uint32 target_id;
    SUserSimple data;

    PRUserSimple() : target_id(0)
    {
        msg_cmd = 1175044508;
    }

    virtual ~PRUserSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRUserSimple(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRUserSimple";
    }
};

#endif
