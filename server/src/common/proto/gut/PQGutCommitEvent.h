#ifndef _PQGutCommitEvent_H_
#define _PQGutCommitEvent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*事件验证基类*/
class PQGutCommitEvent : public SMsgHead
{
public:
    int32 index;    //剧情事件会包含多个处理步骤(从0开始) 

    PQGutCommitEvent() : index(0)
    {
        msg_cmd = 813604863;
    }

    virtual ~PQGutCommitEvent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGutCommitEvent(*this) );
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
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQGutCommitEvent";
    }
};

#endif
