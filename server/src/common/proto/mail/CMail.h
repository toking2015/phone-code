#ifndef _CMail_H_
#define _CMail_H_

#include <weedong/core/seq/seq.h>
/*==========================数据中心========================*/
class CMail : public wd::CSeq
{
public:
    uint32 system_mail_id;    //当前系统邮件最大Id

    CMail() : system_mail_id(0)
    {
    }

    virtual ~CMail()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CMail(*this) );
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
            && TFVarTypeProcess( system_mail_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CMail";
    }
};

#endif
