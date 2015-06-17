#ifndef _PQPayNotice_H_
#define _PQPayNotice_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*======================服务器中转====================*/
class PQPayNotice : public SMsgHead
{
public:
    uint32 target_id;    //realdb 通知 game

    PQPayNotice() : target_id(0)
    {
        msg_cmd = 721071533;
    }

    virtual ~PQPayNotice()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPayNotice(*this) );
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
        return "PQPayNotice";
    }
};

#endif
