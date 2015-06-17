#ifndef _PRShopLog_H_
#define _PRShopLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/shop/SUserShopLog.h>

class PRShopLog : public SMsgHead
{
public:
    std::vector< SUserShopLog > log;

    PRShopLog()
    {
        msg_cmd = 1391203940;
    }

    virtual ~PRShopLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRShopLog(*this) );
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
            && TFVarTypeProcess( log, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRShopLog";
    }
};

#endif
