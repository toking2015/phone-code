#ifndef _SUserTask_H_
#define _SUserTask_H_

#include <weedong/core/seq/seq.h>
/*任务-黄少卿*/
class SUserTask : public wd::CSeq
{
public:
    uint32 task_id;
    uint32 cond;    //任务条件完成值
    uint32 create_time;    //任务接受时间

    SUserTask() : task_id(0), cond(0), create_time(0)
    {
    }

    virtual ~SUserTask()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTask(*this) );
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
            && TFVarTypeProcess( cond, eType, stream, uiSize )
            && TFVarTypeProcess( create_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserTask";
    }
};

#endif
