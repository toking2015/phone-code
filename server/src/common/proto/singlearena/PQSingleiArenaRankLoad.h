#ifndef _PQSingleiArenaRankLoad_H_
#define _PQSingleiArenaRankLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*加载排行榜数据*/
class PQSingleiArenaRankLoad : public SMsgHead
{
public:

    PQSingleiArenaRankLoad()
    {
        msg_cmd = 506417845;
    }

    virtual ~PQSingleiArenaRankLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleiArenaRankLoad(*this) );
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
        return "PQSingleiArenaRankLoad";
    }
};

#endif
