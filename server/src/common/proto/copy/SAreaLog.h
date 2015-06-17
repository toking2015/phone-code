#ifndef _SAreaLog_H_
#define _SAreaLog_H_

#include <weedong/core/seq/seq.h>
/*区域通关记录*/
class SAreaLog : public wd::CSeq
{
public:
    uint32 area_id;    //区域id( copy_id / 1000 )
    uint32 normal_full_take_time;    //普通区域满星领奖时间
    uint32 elite_full_take_time;    //精英区域满星领奖时间
    uint32 normal_pass_take_time;    //普通区域通关领奖时间
    uint32 elite_pass_take_time;    //精英区域通关领奖时间

    SAreaLog() : area_id(0), normal_full_take_time(0), elite_full_take_time(0), normal_pass_take_time(0), elite_pass_take_time(0)
    {
    }

    virtual ~SAreaLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SAreaLog(*this) );
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
            && TFVarTypeProcess( area_id, eType, stream, uiSize )
            && TFVarTypeProcess( normal_full_take_time, eType, stream, uiSize )
            && TFVarTypeProcess( elite_full_take_time, eType, stream, uiSize )
            && TFVarTypeProcess( normal_pass_take_time, eType, stream, uiSize )
            && TFVarTypeProcess( elite_pass_take_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SAreaLog";
    }
};

#endif
