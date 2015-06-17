#ifndef _PQTaskFinish_H_
#define _PQTaskFinish_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@任务完成*/
class PQTaskFinish : public SMsgHead
{
public:
    uint32 task_id;

    PQTaskFinish() : task_id(0)
    {
        msg_cmd = 403585854;
    }

    virtual ~PQTaskFinish()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTaskFinish(*this) );
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
        return "PQTaskFinish";
    }
};

#endif
