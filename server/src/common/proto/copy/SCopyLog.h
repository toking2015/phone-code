#ifndef _SCopyLog_H_
#define _SCopyLog_H_

#include <weedong/core/seq/seq.h>
/*副本记录, 只有 SUserCopy.status 带有 kCopyStateBossCol 状态并且通关后才会该记录*/
class SCopyLog : public wd::CSeq
{
public:
    uint32 copy_id;    //通关副本Id
    uint32 time;    //通关时间

    SCopyLog() : copy_id(0), time(0)
    {
    }

    virtual ~SCopyLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SCopyLog(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( copy_id, eType, stream, uiSize )
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SCopyLog";
    }
};

#endif
