#ifndef _SUserTaskDay_H_
#define _SUserTaskDay_H_

#include <weedong/core/seq/seq.h>
/*日常任务记录(每天清空)*/
class SUserTaskDay : public wd::CSeq
{
public:
    uint32 task_id;
    uint32 create_time;    //任务接受时间
    uint32 finish_time;    //任务完成时间

    SUserTaskDay() : task_id(0), create_time(0), finish_time(0)
    {
    }

    virtual ~SUserTaskDay()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTaskDay(*this) );
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
        return "SUserTaskDay";
    }
};

#endif
