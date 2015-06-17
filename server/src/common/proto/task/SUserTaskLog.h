#ifndef _SUserTaskLog_H_
#define _SUserTaskLog_H_

#include <weedong/core/seq/seq.h>
/*用于保存 主线任务,支线任务,活动任务 的任务记录( 日常任务不保存完成记录 )*/
class SUserTaskLog : public wd::CSeq
{
public:
    uint32 task_id;
    uint32 create_time;    //任务接受时间
    uint32 finish_time;    //任务完成时间

    SUserTaskLog() : task_id(0), create_time(0), finish_time(0)
    {
    }

    virtual ~SUserTaskLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTaskLog(*this) );
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
            && TFVarTypeProcess( task_id, eType, stream, uiSize )
            && TFVarTypeProcess( create_time, eType, stream, uiSize )
            && TFVarTypeProcess( finish_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserTaskLog";
    }
};

#endif
