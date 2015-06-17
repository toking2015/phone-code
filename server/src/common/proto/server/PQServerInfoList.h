#ifndef _PQServerInfoList_H_
#define _PQServerInfoList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*服务器变量列表处理*/
class PQServerInfoList : public SMsgHead
{
public:

    PQServerInfoList()
    {
        msg_cmd = 993184889;
    }

    virtual ~PQServerInfoList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQServerInfoList(*this) );
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
        return "PQServerInfoList";
    }
};

#endif
