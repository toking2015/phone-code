#ifndef _PQAuthRunJson_H_
#define _PQAuthRunJson_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*=========================通迅协议============================*/
class PQAuthRunJson : public SMsgHead
{
public:
    int32 outside_sock;    //外部连接
    std::string json_string;    //执行字符串

    PQAuthRunJson() : outside_sock(0)
    {
        msg_cmd = 110123182;
    }

    virtual ~PQAuthRunJson()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQAuthRunJson(*this) );
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
            && TFVarTypeProcess( json_string, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQAuthRunJson";
    }
};

#endif
