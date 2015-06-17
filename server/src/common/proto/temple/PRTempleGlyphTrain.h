#ifndef _PRTempleGlyphTrain_H_
#define _PRTempleGlyphTrain_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTempleGlyphTrain : public SMsgHead
{
public:
    uint32 old_lv;
    uint32 new_lv;

    PRTempleGlyphTrain() : old_lv(0), new_lv(0)
    {
        msg_cmd = 1477567015;
    }

    virtual ~PRTempleGlyphTrain()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTempleGlyphTrain(*this) );
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
            && TFVarTypeProcess( old_lv, eType, stream, uiSize )
            && TFVarTypeProcess( new_lv, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTempleGlyphTrain";
    }
};

#endif
