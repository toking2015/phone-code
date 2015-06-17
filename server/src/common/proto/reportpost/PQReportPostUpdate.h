#ifndef _PQReportPostUpdate_H_
#define _PQReportPostUpdate_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQReportPostUpdate : public SMsgHead
{
public:
    uint8 set_type;    //kObjecAdd, kObjecDel
    uint32 target_id;    //被举报者role_id
    uint32 report_id;    //举报者role_id
    uint32 report_time;    //举报者时间,　　其实内部处理只用SReportPostInfo.report_time

    PQReportPostUpdate() : set_type(0), target_id(0), report_id(0), report_time(0)
    {
        msg_cmd = 217565280;
    }

    virtual ~PQReportPostUpdate()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQReportPostUpdate(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( report_id, eType, stream, uiSize )
            && TFVarTypeProcess( report_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQReportPostUpdate";
    }
};

#endif
