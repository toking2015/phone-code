#ifndef _CRankCenter_H_
#define _CRankCenter_H_

#include <weedong/core/seq/seq.h>
#include <proto/rank/CRank.h>

/*============================数据中心========================*/
class CRankCenter : public wd::CSeq
{
public:
    std::map< uint32, CRank > real_map;    //即时排行榜
    std::map< uint32, CRank > copy_map;    //记录排行榜

    CRankCenter()
    {
    }

    virtual ~CRankCenter()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CRankCenter(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( real_map, eType, stream, uiSize )
            && TFVarTypeProcess( copy_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CRankCenter";
    }
};

#endif
