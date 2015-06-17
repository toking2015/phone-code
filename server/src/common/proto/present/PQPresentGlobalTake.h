#ifndef _PQPresentGlobalTake_H_
#define _PQPresentGlobalTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求获取全局礼包领取*/
class PQPresentGlobalTake : public SMsgHead
{
public:
    std::string platform;    //平台key(服务器自动修改, 客户端不用填写)
    std::string code;    //激活礼包key

    PQPresentGlobalTake()
    {
        msg_cmd = 244129486;
    }

    virtual ~PQPresentGlobalTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPresentGlobalTake(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( platform, eType, stream, uiSize )
            && TFVarTypeProcess( code, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPresentGlobalTake";
    }
};

#endif
