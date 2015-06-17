#ifndef _SSignInfo_H_
#define _SSignInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/sign/SSign.h>

class SSignInfo : public wd::CSeq
{
public:
    std::vector< SSign > sign_list;    // 签到列表
    std::vector< uint32 > sum_list;    // 累计签到已领取奖励id列表

    SSignInfo()
    {
    }

    virtual ~SSignInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSignInfo(*this) );
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
            && TFVarTypeProcess( sign_list, eType, stream, uiSize )
            && TFVarTypeProcess( sum_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSignInfo";
    }
};

#endif
