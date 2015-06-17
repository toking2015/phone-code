#ifndef _PQShopLog_H_
#define _PQShopLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求购买记录*/
class PQShopLog : public SMsgHead
{
public:

    PQShopLog()
    {
        msg_cmd = 842024592;
    }

    virtual ~PQShopLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQShopLog(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQShopLog";
    }
};

#endif
