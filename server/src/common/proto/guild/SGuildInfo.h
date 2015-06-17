#ifndef _SGuildInfo_H_
#define _SGuildInfo_H_

#include <weedong/core/seq/seq.h>
/*公会基本信息结构*/
class SGuildInfo : public wd::CSeq
{
public:
    uint32 create_time;    //创建日期
    uint32 xp;    //经验
    std::string post_msg;    //公告

    SGuildInfo() : create_time(0), xp(0)
    {
    }

    virtual ~SGuildInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildInfo(*this) );
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
            && TFVarTypeProcess( create_time, eType, stream, uiSize )
            && TFVarTypeProcess( xp, eType, stream, uiSize )
            && TFVarTypeProcess( post_msg, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildInfo";
    }
};

#endif
