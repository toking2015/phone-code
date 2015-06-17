#ifndef _PQCopyFightLogLoad_H_
#define _PQCopyFightLogLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQCopyFightLogLoad : public SMsgHead
{
public:
    uint32 copy_id;

    PQCopyFightLogLoad() : copy_id(0)
    {
        msg_cmd = 860903992;
    }

    virtual ~PQCopyFightLogLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyFightLogLoad(*this) );
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
        return "PQCopyFightLogLoad";
    }
};

#endif
