#ifndef _PQTaskLogList_H_
#define _PQTaskLogList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求任务记录列表*/
class PQTaskLogList : public SMsgHead
{
public:

    PQTaskLogList()
    {
        msg_cmd = 690366673;
    }

    virtual ~PQTaskLogList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTaskLogList(*this) );
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
        return "PQTaskLogList";
    }
};

#endif
