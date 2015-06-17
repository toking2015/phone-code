#ifndef _PQSingleiArenaInfo_H_
#define _PQSingleiArenaInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*获取基本信息*/
class PQSingleiArenaInfo : public SMsgHead
{
public:

    PQSingleiArenaInfo()
    {
        msg_cmd = 11025237;
    }

    virtual ~PQSingleiArenaInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleiArenaInfo(*this) );
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
        return "PQSingleiArenaInfo";
    }
};

#endif
