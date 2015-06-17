#ifndef _PQCopyOpen_H_
#define _PQCopyOpen_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@*/
class PQCopyOpen : public SMsgHead
{
public:
    uint32 copy_id;    //副本Id

    PQCopyOpen() : copy_id(0)
    {
        msg_cmd = 443612719;
    }

    virtual ~PQCopyOpen()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyOpen(*this) );
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
        return "PQCopyOpen";
    }
};

#endif
