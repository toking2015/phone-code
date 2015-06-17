#ifndef _PQSingleArenaRank_H_
#define _PQSingleArenaRank_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*申请排行榜数据*/
class PQSingleArenaRank : public SMsgHead
{
public:
    uint32 index;    //从第几名开始
    uint32 count;    //数量

    PQSingleArenaRank() : index(0), count(0)
    {
        msg_cmd = 133216982;
    }

    virtual ~PQSingleArenaRank()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSingleArenaRank(*this) );
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
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSingleArenaRank";
    }
};

#endif
