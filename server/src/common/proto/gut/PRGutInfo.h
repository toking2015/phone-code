#ifndef _PRGutInfo_H_
#define _PRGutInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/gut/SGutInfo.h>

class PRGutInfo : public SMsgHead
{
public:
    SGutInfo data;

    PRGutInfo()
    {
        msg_cmd = 1993357244;
    }

    virtual ~PRGutInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGutInfo(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGutInfo";
    }
};

#endif
