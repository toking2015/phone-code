#ifndef _PRRankLoad_H_
#define _PRRankLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/rank/SRankData.h>

/*返回记录排行榜数据*/
class PRRankLoad : public SMsgHead
{
public:
    uint8 rank_type;    //kRankingTypeXXX
    uint8 rank_attr;    //kRankAttrYYY
    std::vector< SRankData > list;    //排行数据

    PRRankLoad() : rank_type(0), rank_attr(0)
    {
        msg_cmd = 2011706770;
    }

    virtual ~PRRankLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRRankLoad(*this) );
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
            && TFVarTypeProcess( rank_type, eType, stream, uiSize )
            && TFVarTypeProcess( rank_attr, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRRankLoad";
    }
};

#endif
