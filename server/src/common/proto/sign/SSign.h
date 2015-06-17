#ifndef _SSign_H_
#define _SSign_H_

#include <weedong/core/seq/seq.h>
/* 每日签到*/
class SSign : public wd::CSeq
{
public:
    uint32 day_id;    // 签到日期id
    uint32 sign_type;    // 签到类型, kSignNormal或kSignAdditional
    uint32 sign_time;    // 签到时间

    SSign() : day_id(0), sign_type(0), sign_time(0)
    {
    }

    virtual ~SSign()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSign(*this) );
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
            && TFVarTypeProcess( day_id, eType, stream, uiSize )
            && TFVarTypeProcess( sign_type, eType, stream, uiSize )
            && TFVarTypeProcess( sign_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSign";
    }
};

#endif
