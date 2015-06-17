#ifndef _SReportPostInfo_H_
#define _SReportPostInfo_H_

#include <weedong/core/seq/seq.h>
/*举报系统-王子浪*/
class SReportPostInfo : public wd::CSeq
{
public:
    uint32 target_id;
    uint32 report_time;    //举报时间点，如果当前时间 大于 “举报时间限期”　+　report_time 就清空target_list
    std::vector< uint32 > report_list;    //举报者id

    SReportPostInfo() : target_id(0), report_time(0)
    {
    }

    virtual ~SReportPostInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SReportPostInfo(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( report_time, eType, stream, uiSize )
            && TFVarTypeProcess( report_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SReportPostInfo";
    }
};

#endif
