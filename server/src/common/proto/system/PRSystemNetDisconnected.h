#ifndef _PRSystemNetDisconnected_H_
#define _PRSystemNetDisconnected_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*网络连接断开*/
class PRSystemNetDisconnected : public SMsgHead
{
public:

    PRSystemNetDisconnected()
    {
        msg_cmd = 1462459954;
    }

    virtual ~PRSystemNetDisconnected()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemNetDisconnected(*this) );
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
        return "PRSystemNetDisconnected";
    }
};

#endif
