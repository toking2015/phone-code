#ifndef _PQTaskAutoFinish_H_
#define _PQTaskAutoFinish_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@任务自动完成*/
class PQTaskAutoFinish : public SMsgHead
{
public:
    uint32 task_id;

    PQTaskAutoFinish() : task_id(0)
    {
        msg_cmd = 869618664;
    }

    virtual ~PQTaskAutoFinish()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTaskAutoFinish(*this) );
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
        return "PQTaskAutoFinish";
    }
};

#endif
