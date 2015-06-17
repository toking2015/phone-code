#ifndef _PRReportPostMake_H_
#define _PRReportPostMake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*举报返回协议，作为是成功等提示*/
class PRReportPostMake : public SMsgHead
{
public:
    uint32 target_id;    //被举报者guid

    PRReportPostMake() : target_id(0)
    {
        msg_cmd = 1560889071;
    }

    virtual ~PRReportPostMake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRReportPostMake(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRReportPostMake";
    }
};

#endif
