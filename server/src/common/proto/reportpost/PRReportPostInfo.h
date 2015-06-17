#ifndef _PRReportPostInfo_H_
#define _PRReportPostInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/reportpost/SReportPostInfo.h>

class PRReportPostInfo : public SMsgHead
{
public:
    SReportPostInfo info;

    PRReportPostInfo()
    {
        msg_cmd = 1987315945;
    }

    virtual ~PRReportPostInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRReportPostInfo(*this) );
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
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRReportPostInfo";
    }
};

#endif
