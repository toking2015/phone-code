#ifndef _PRSystemErrCode_H_
#define _PRSystemErrCode_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*错误通知协议*/
class PRSystemErrCode : public SMsgHead
{
public:
    uint32 err_no;
    uint32 err_desc;

    PRSystemErrCode() : err_no(0), err_desc(0)
    {
        msg_cmd = 1465167678;
    }

    virtual ~PRSystemErrCode()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemErrCode(*this) );
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
            && TFVarTypeProcess( err_no, eType, stream, uiSize )
            && TFVarTypeProcess( err_desc, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSystemErrCode";
    }
};

#endif
