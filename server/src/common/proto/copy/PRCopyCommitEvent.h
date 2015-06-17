#ifndef _PRCopyCommitEvent_H_
#define _PRCopyCommitEvent_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*失败返回*/
class PRCopyCommitEvent : public SMsgHead
{
public:
    int32 posi;
    int32 index;
    int32 result;    //0为正常, !=0 为错误码

    PRCopyCommitEvent() : posi(0), index(0), result(0)
    {
        msg_cmd = 1829634408;
    }

    virtual ~PRCopyCommitEvent()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyCommitEvent(*this) );
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
            && TFVarTypeProcess( result, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyCommitEvent";
    }
};

#endif
