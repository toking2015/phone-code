#ifndef _SUserTop_H_
#define _SUserTop_H_

#include <weedong/core/seq/seq.h>
/*用户排行相关信息*/
class SUserTop : public wd::CSeq
{
public:
    uint32 dailygain_time;    //日增变量时间戳
    uint32 dailygain_xp;    //日增经验值
    uint16 dailygain_soldier;    //日增武将数量
    uint32 dailygain_fame;    //日增名望值

    SUserTop() : dailygain_time(0), dailygain_xp(0), dailygain_soldier(0), dailygain_fame(0)
    {
    }

    virtual ~SUserTop()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserTop(*this) );
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
            && TFVarTypeProcess( dailygain_time, eType, stream, uiSize )
            && TFVarTypeProcess( dailygain_xp, eType, stream, uiSize )
            && TFVarTypeProcess( dailygain_soldier, eType, stream, uiSize )
            && TFVarTypeProcess( dailygain_fame, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserTop";
    }
};

#endif
