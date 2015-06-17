#ifndef _PRAuthRunTimeSet_H_
#define _PRAuthRunTimeSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/auth/SAuthRunTime.h>

class PRAuthRunTimeSet : public SMsgHead
{
public:
    int32 outside_sock;    //外部连接
    uint8 set_type;
    SAuthRunTime run_time;

    PRAuthRunTimeSet() : outside_sock(0), set_type(0)
    {
        msg_cmd = 1140596663;
    }

    virtual ~PRAuthRunTimeSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRAuthRunTimeSet(*this) );
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
            && TFVarTypeProcess( outside_sock, eType, stream, uiSize )
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( run_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRAuthRunTimeSet";
    }
};

#endif
