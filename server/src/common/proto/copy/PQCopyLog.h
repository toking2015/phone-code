#ifndef _PQCopyLog_H_
#define _PQCopyLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求副本记录*/
class PQCopyLog : public SMsgHead
{
public:
    uint32 copy_id;

    PQCopyLog() : copy_id(0)
    {
        msg_cmd = 942268467;
    }

    virtual ~PQCopyLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyLog(*this) );
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
            && TFVarTypeProcess( copy_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyLog";
    }
};

#endif
