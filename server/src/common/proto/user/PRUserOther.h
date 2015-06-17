#ifndef _PRUserOther_H_
#define _PRUserOther_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/user/SUserOther.h>

class PRUserOther : public SMsgHead
{
public:
    SUserOther other;

    PRUserOther()
    {
        msg_cmd = 2131699547;
    }

    virtual ~PRUserOther()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRUserOther(*this) );
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
            && TFVarTypeProcess( other, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRUserOther";
    }
};

#endif
