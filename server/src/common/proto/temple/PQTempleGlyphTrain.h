#ifndef _PQTempleGlyphTrain_H_
#define _PQTempleGlyphTrain_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 神符升级*/
class PQTempleGlyphTrain : public SMsgHead
{
public:
    uint32 main_guid;    // 吞噬神符guid
    uint32 eated_guid;    // 被吞噬神符guid

    PQTempleGlyphTrain() : main_guid(0), eated_guid(0)
    {
        msg_cmd = 198720182;
    }

    virtual ~PQTempleGlyphTrain()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTempleGlyphTrain(*this) );
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
            && TFVarTypeProcess( main_guid, eType, stream, uiSize )
            && TFVarTypeProcess( eated_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTempleGlyphTrain";
    }
};

#endif
