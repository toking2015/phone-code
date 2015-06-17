#ifndef _PQMailWrite_H_
#define _PQMailWrite_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*=========================通迅协议============================*/
class PQMailWrite : public SMsgHead
{
public:
    uint32 target_id;    //角色Id
    std::string subject;    //邮件标题
    std::string body;    //邮件正文
    std::vector< S3UInt32 > coins;    //附件数据

    PQMailWrite() : target_id(0)
    {
        msg_cmd = 281547260;
    }

    virtual ~PQMailWrite()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMailWrite(*this) );
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
            && TFVarTypeProcess( subject, eType, stream, uiSize )
            && TFVarTypeProcess( body, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMailWrite";
    }
};

#endif
