#ifndef _PRCopyAreaPresentTake_H_
#define _PRCopyAreaPresentTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRCopyAreaPresentTake : public SMsgHead
{
public:
    uint8 mopup_type;
    uint8 area_attr;
    uint32 area_id;

    PRCopyAreaPresentTake() : mopup_type(0), area_attr(0), area_id(0)
    {
        msg_cmd = 1845809709;
    }

    virtual ~PRCopyAreaPresentTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyAreaPresentTake(*this) );
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
            && TFVarTypeProcess( mopup_type, eType, stream, uiSize )
            && TFVarTypeProcess( area_attr, eType, stream, uiSize )
            && TFVarTypeProcess( area_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyAreaPresentTake";
    }
};

#endif
