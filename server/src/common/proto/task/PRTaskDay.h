#ifndef _PRTaskDay_H_
#define _PRTaskDay_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/task/SUserTaskDay.h>

/*返回单个日常任务记录( 只增改 )*/
class PRTaskDay : public SMsgHead
{
public:
    SUserTaskDay data;

    PRTaskDay()
    {
        msg_cmd = 1238179220;
    }

    virtual ~PRTaskDay()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskDay(*this) );
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
        return "PRTaskDay";
    }
};

#endif
