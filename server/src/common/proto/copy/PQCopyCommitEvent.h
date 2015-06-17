#ifndef _PQCopyCommitEvent_H_
#define _PQCopyCommitEvent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*事件验证基类*/
class PQCopyCommitEvent : public SMsgHead
{
public:
    int32 posi;    //进度索引(从0开始)
    int32 index;    //同一进度事件内的序列, 剧情事件会包含多个处理步骤(从0开始)

    PQCopyCommitEvent() : posi(0), index(0)
    {
        msg_cmd = 463078305;
    }

    virtual ~PQCopyCommitEvent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyCommitEvent(*this) );
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
            && TFVarTypeProcess( posi, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyCommitEvent";
    }
};

#endif
