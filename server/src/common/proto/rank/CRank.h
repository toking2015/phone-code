#ifndef _CRank_H_
#define _CRank_H_

#include <weedong/core/seq/seq.h>
#include <proto/rank/SRankData.h>
#include <proto/rank/SRankInfo.h>

/*排行榜数据*/
class CRank : public wd::CSeq
{
public:
    std::map< uint32, SRankData > id_data;    //对象数据
    std::vector< SRankInfo > rank;    //排行榜列表

    CRank()
    {
    }

    virtual ~CRank()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CRank(*this) );
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
            && TFVarTypeProcess( id_data, eType, stream, uiSize )
            && TFVarTypeProcess( rank, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CRank";
    }
};

#endif
