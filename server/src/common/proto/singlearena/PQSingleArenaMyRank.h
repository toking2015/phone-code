#ifndef _PQSingleArenaMyRank_H_
#define _PQSingleArenaMyRank_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*申请自己竞技场的当前排名<没有开放的话就不会有 PRSingleArenaMyRank 返回>*/
class PQSingleArenaMyRank : public SMsgHead
{
public:

    PQSingleArenaMyRank()
    {
        msg_cmd = 309320719;
    }

    virtual ~PQSingleArenaMyRank()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleArenaMyRank(*this) );
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
        return "PQSingleArenaMyRank";
    }
};

#endif
