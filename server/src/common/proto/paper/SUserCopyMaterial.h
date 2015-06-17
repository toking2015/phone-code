#ifndef _SUserCopyMaterial_H_
#define _SUserCopyMaterial_H_

#include <weedong/core/seq/seq.h>
/*副本原料*/
class SUserCopyMaterial : public wd::CSeq
{
public:
    uint32 collect_level;    //资源点等级
    uint32 left_collect_times;    //剩余可采集次数
    uint32 del_timestamp;    //满次数时的采集时间戳

    SUserCopyMaterial() : collect_level(0), left_collect_times(0), del_timestamp(0)
    {
    }

    virtual ~SUserCopyMaterial()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserCopyMaterial(*this) );
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
            && TFVarTypeProcess( collect_level, eType, stream, uiSize )
            && TFVarTypeProcess( left_collect_times, eType, stream, uiSize )
            && TFVarTypeProcess( del_timestamp, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserCopyMaterial";
    }
};

#endif
