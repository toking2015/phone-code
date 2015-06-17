#ifndef _PQAuthRunTimeSet_H_
#define _PQAuthRunTimeSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/auth/SAuthRunTime.h>

/*定时执行记录设置*/
class PQAuthRunTimeSet : public SMsgHead
{
public:
    int32 outside_sock;    //外部连接
    uint8 set_type;    //kObjectAdd, kObjectDel
    std::string cmd;
    SAuthRunTime run_time;

    PQAuthRunTimeSet() : outside_sock(0), set_type(0)
    {
        msg_cmd = 149382596;
    }

    virtual ~PQAuthRunTimeSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQAuthRunTimeSet(*this) );
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
            && TFVarTypeProcess( cmd, eType, stream, uiSize )
            && TFVarTypeProcess( run_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQAuthRunTimeSet";
    }
};

#endif
