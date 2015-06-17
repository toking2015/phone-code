#ifndef _PRSystemNetConnected_H_
#define _PRSystemNetConnected_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*网络连接成功*/
class PRSystemNetConnected : public SMsgHead
{
public:

    PRSystemNetConnected()
    {
        msg_cmd = 1761556093;
    }

    virtual ~PRSystemNetConnected()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemNetConnected(*this) );
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
        return "PRSystemNetConnected";
    }
};

#endif
