#ifndef _PRTaskLog_H_
#define _PRTaskLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/task/SUserTaskLog.h>

/*返回任务完成记录( 只增不删 )*/
class PRTaskLog : public SMsgHead
{
public:
    SUserTaskLog data;

    PRTaskLog()
    {
        msg_cmd = 2119306534;
    }

    virtual ~PRTaskLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskLog(*this) );
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
        return "PRTaskLog";
    }
};

#endif
