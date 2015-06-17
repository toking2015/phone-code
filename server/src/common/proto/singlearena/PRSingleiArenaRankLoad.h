#ifndef _PRSingleiArenaRankLoad_H_
#define _PRSingleiArenaRankLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/singlearena/SSingleArenaOpponent.h>

class PRSingleiArenaRankLoad : public SMsgHead
{
public:
    std::vector< SSingleArenaOpponent > list;

    PRSingleiArenaRankLoad()
    {
        msg_cmd = 1875925767;
    }

    virtual ~PRSingleiArenaRankLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleiArenaRankLoad(*this) );
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
            && TFVarTypeProcess( list, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleiArenaRankLoad";
    }
};

#endif
