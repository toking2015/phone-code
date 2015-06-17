#ifndef _SUserMail_H_
#define _SUserMail_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*==========================通迅结构==========================*/
class SUserMail : public wd::CSeq
{
public:
    uint32 mail_id;
    uint32 flag;    //状态
    uint32 path;    //途径 [kPath]
    uint32 deliver_time;    //发送时间
    std::string sender_name;    //发送者名称
    std::string subject;    //标题
    std::string body;    //内容
    std::vector< S3UInt32 > coins;    //附件
    uint32 coin_flag;    //货币属性

    SUserMail() : mail_id(0), flag(0), path(0), deliver_time(0), coin_flag(0)
    {
    }

    virtual ~SUserMail()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserMail(*this) );
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
            && TFVarTypeProcess( mail_id, eType, stream, uiSize )
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && TFVarTypeProcess( path, eType, stream, uiSize )
            && TFVarTypeProcess( deliver_time, eType, stream, uiSize )
            && TFVarTypeProcess( sender_name, eType, stream, uiSize )
            && TFVarTypeProcess( subject, eType, stream, uiSize )
            && TFVarTypeProcess( body, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && TFVarTypeProcess( coin_flag, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserMail";
    }
};

#endif
