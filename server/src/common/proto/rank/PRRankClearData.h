#ifndef _PRRankClearData_H_
#define _PRRankClearData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRRankClearData : public SMsgHead
{
public:
    uint8 rank_type;    //kRankingTypeXXX

    PRRankClearData() : rank_type(0)
    {
        msg_cmd = 1386335833;
    }

    virtual ~PRRankClearData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRRankClearData(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRRankClearData";
    }
};

#endif
