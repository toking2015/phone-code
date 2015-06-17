#ifndef _PRRankIndex_H_
#define _PRRankIndex_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/rank/SRankData.h>

/*返回指定id在排行榜中的位置*/
class PRRankIndex : public SMsgHead
{
public:
    uint32 limit;    //分阶
    uint8 rank_type;    //kRankingTypeXXX
    uint8 rank_attr;    //kRankAttrYYY
    uint32 target_id;    //查询id
    int32 index;    //顺位索引( 从0开始, 不存在返回 -1 )
    SRankData data;

    PRRankIndex() : limit(0), rank_type(0), rank_attr(0), target_id(0), index(0)
    {
        msg_cmd = 1385163042;
    }

    virtual ~PRRankIndex()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRRankIndex(*this) );
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
            && TFVarTypeProcess( rank_attr, eType, stream, uiSize )
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRRankIndex";
    }
};

#endif
