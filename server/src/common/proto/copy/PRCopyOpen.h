#ifndef _PRCopyOpen_H_
#define _PRCopyOpen_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/SCompressData.h>

class PRCopyOpen : public SMsgHead
{
public:
    SCompressData data;    //副本数据
    int32 result;

    PRCopyOpen() : result(0)
    {
        msg_cmd = 1180545869;
    }

    virtual ~PRCopyOpen()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyOpen(*this) );
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
            && TFVarTypeProcess( result, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyOpen";
    }
};

#endif
