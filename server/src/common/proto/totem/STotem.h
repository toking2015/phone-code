#ifndef _STotem_H_
#define _STotem_H_

#include <weedong/core/seq/seq.h>
/* 图腾*/
class STotem : public wd::CSeq
{
public:
    uint32 guid;    // guid
    uint32 id;    // 图腾id
    uint32 level;    // 图腾等级
    uint32 speed_lv;    // 速度等级
    uint32 formation_add_lv;    // 阵法加成等级
    uint32 wake_lv;    // 觉醒等级
    uint32 energy_time;    // 充能时间
    uint32 accelerate_count;    // 加速次数

    STotem() : guid(0), id(0), level(0), speed_lv(0), formation_add_lv(0), wake_lv(0), energy_time(0), accelerate_count(0)
    {
    }

    virtual ~STotem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STotem(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( speed_lv, eType, stream, uiSize )
            && TFVarTypeProcess( formation_add_lv, eType, stream, uiSize )
            && TFVarTypeProcess( wake_lv, eType, stream, uiSize )
            && TFVarTypeProcess( energy_time, eType, stream, uiSize )
            && TFVarTypeProcess( accelerate_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STotem";
    }
};

#endif
