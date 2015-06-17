#ifndef _PRReportPostInfoLoad_H_
#define _PRReportPostInfoLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/reportpost/SReportPostInfo.h>

class PRReportPostInfoLoad : public SMsgHead
{
public:
    std::map< uint32, SReportPostInfo > info_map;

    PRReportPostInfoLoad()
    {
        msg_cmd = 1596177775;
    }

    virtual ~PRReportPostInfoLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRReportPostInfoLoad(*this) );
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
            && TFVarTypeProcess( info_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRReportPostInfoLoad";
    }
};

#endif
