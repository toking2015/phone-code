#ifndef _PRSingleArenaMyRank_H_
#define _PRSingleArenaMyRank_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRSingleArenaMyRank : public SMsgHead
{
public:
    uint32 rank;    //当前排名

    PRSingleArenaMyRank() : rank(0)
    {
        msg_cmd = 1122082782;
    }

    virtual ~PRSingleArenaMyRank()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaMyRank(*this) );
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
            && TFVarTypeProcess( rank, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaMyRank";
    }
};

#endif
