#ifndef _PRCopyClose_H_
#define _PRCopyClose_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRCopyClose : public SMsgHead
{
public:
    int32 result;    //0为正常, != 0 为错误码

    PRCopyClose() : result(0)
    {
        msg_cmd = 1145076953;
    }

    virtual ~PRCopyClose()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyClose(*this) );
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
            && TFVarTypeProcess( result, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyClose";
    }
};

#endif
