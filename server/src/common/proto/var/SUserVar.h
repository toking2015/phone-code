#ifndef _SUserVar_H_
#define _SUserVar_H_

#include <weedong/core/seq/seq.h>
/*=========================数据结构============================*/
class SUserVar : public wd::CSeq
{
public:
    uint32 value;    //变量值
    uint32 timelimit;    //有效期( 结束时间截, 0 为永远有效 )

    SUserVar() : value(0), timelimit(0)
    {
    }

    virtual ~SUserVar()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserVar(*this) );
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
            && TFVarTypeProcess( value, eType, stream, uiSize )
            && TFVarTypeProcess( timelimit, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserVar";
    }
};

#endif
