#ifndef _PQRankCopySave_H_
#define _PQRankCopySave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/rank/SRankData.h>

/*将记录排行榜数据进行保存*/
class PQRankCopySave : public SMsgHead
{
public:
    uint8 rank_type;    //kRankingTypeXXXX
    uint8 set_type;    //kObjectDel, kObjectAdd
    std::vector< SRankData > list;    //排行数据

    PQRankCopySave() : rank_type(0), set_type(0)
    {
        msg_cmd = 479530750;
    }

    virtual ~PQRankCopySave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQRankCopySave(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQRankCopySave";
    }
};

#endif
