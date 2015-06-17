#ifndef _PQUserSimple_H_
#define _PQUserSimple_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*=========================通迅协议============================*/
class PQUserSimple : public SMsgHead
{
public:
    uint32 target_id;

    PQUserSimple() : target_id(0)
    {
        msg_cmd = 455141318;
    }

    virtual ~PQUserSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQUserSimple(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQUserSimple";
    }
};

#endif
