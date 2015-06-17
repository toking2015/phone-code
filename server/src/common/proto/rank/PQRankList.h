#ifndef _PQRankList_H_
#define _PQRankList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求排行榜列表*/
class PQRankList : public SMsgHead
{
public:
    uint32 limit;    //分阶
    uint8 rank_type;    //kRankingTypeXXX
    uint32 index;    //获取起始偏移索引
    uint8 count;    //获取条数( 不建议一次过请求超过100条 )

    PQRankList() : limit(0), rank_type(0), index(0), count(0)
    {
        msg_cmd = 612777078;
    }

    virtual ~PQRankList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQRankList(*this) );
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
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQRankList";
    }
};

#endif
