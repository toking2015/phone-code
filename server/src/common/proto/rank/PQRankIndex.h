#ifndef _PQRankIndex_H_
#define _PQRankIndex_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*请求指定id在指定排行榜中的索引位置(从0开始)*/
class PQRankIndex : public SMsgHead
{
public:
    uint32 limit;    //分阶
    uint8 rank_type;    //kRankingTypeXXX
    uint8 rank_attr;    //kRankAttrYYY
    uint32 target_id;    //查询id

    PQRankIndex() : limit(0), rank_type(0), rank_attr(0), target_id(0)
    {
        msg_cmd = 534066083;
    }

    virtual ~PQRankIndex()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQRankIndex(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQRankIndex";
    }
};

#endif
