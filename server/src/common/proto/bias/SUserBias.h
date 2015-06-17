#ifndef _SUserBias_H_
#define _SUserBias_H_

#include <weedong/core/seq/seq.h>
/*阵型-印佳*/
class SUserBias : public wd::CSeq
{
public:
    uint32 bias_id;    //掉落id
    uint32 use_count;    //使用次数
    uint32 day_count;    //一天获得次数

    SUserBias() : bias_id(0), use_count(0), day_count(0)
    {
    }

    virtual ~SUserBias()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserBias(*this) );
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
            && TFVarTypeProcess( bias_id, eType, stream, uiSize )
            && TFVarTypeProcess( use_count, eType, stream, uiSize )
            && TFVarTypeProcess( day_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserBias";
    }
};

#endif
