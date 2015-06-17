#ifndef _PQGuildSimpleList_H_
#define _PQGuildSimpleList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*所有公会基本信息列表请求(用于服务器初始化)*/
class PQGuildSimpleList : public SMsgHead
{
public:

    PQGuildSimpleList()
    {
        msg_cmd = 433483323;
    }

    virtual ~PQGuildSimpleList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGuildSimpleList(*this) );
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
        return "PQGuildSimpleList";
    }
};

#endif
