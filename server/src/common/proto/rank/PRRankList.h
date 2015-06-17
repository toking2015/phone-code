#ifndef _PRRankList_H_
#define _PRRankList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/rank/SRankData.h>

/*返回排行榜列表*/
class PRRankList : public SMsgHead
{
public:
    uint32 limit;    //分阶
    uint8 rank_type;    //kRankingTypeXXX
    uint32 index;    //获取起始偏移索引
    uint32 sum;    //排行榜总条数
    std::vector< SRankData > list;    //返回数据集

    PRRankList() : limit(0), rank_type(0), index(0), sum(0)
    {
        msg_cmd = 2140059588;
    }

    virtual ~PRRankList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRRankList(*this) );
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
            && TFVarTypeProcess( limit, eType, stream, uiSize )
            && TFVarTypeProcess( rank_type, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( sum, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRRankList";
    }
};

#endif
