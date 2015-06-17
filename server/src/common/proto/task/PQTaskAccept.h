#ifndef _PQTaskAccept_H_
#define _PQTaskAccept_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求接受任务*/
class PQTaskAccept : public SMsgHead
{
public:
    uint32 task_id;

    PQTaskAccept() : task_id(0)
    {
        msg_cmd = 896801999;
    }

    virtual ~PQTaskAccept()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTaskAccept(*this) );
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
            && TFVarTypeProcess( task_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTaskAccept";
    }
};

#endif
