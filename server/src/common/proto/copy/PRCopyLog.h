#ifndef _PRCopyLog_H_
#define _PRCopyLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/copy/SCopyLog.h>

/*返回副本记录*/
class PRCopyLog : public SMsgHead
{
public:
    SCopyLog data;

    PRCopyLog()
    {
        msg_cmd = 1481077064;
    }

    virtual ~PRCopyLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyLog(*this) );
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
        return "PRCopyLog";
    }
};

#endif
