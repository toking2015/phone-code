#ifndef _PQPayInfo_H_
#define _PQPayInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求Pay信息*/
class PQPayInfo : public SMsgHead
{
public:

    PQPayInfo()
    {
        msg_cmd = 676129012;
    }

    virtual ~PQPayInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQPayInfo(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQPayInfo";
    }
};

#endif
