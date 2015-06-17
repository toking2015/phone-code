#ifndef _PQCoinData_H_
#define _PQCoinData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求货币数据*/
class PQCoinData : public SMsgHead
{
public:

    PQCoinData()
    {
        msg_cmd = 378549693;
    }

    virtual ~PQCoinData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCoinData(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PQCoinData";
    }
};

#endif
