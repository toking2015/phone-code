#ifndef _PQTotemGlyphMerge_H_
#define _PQTotemGlyphMerge_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/* 雕文合成*/
class PQTotemGlyphMerge : public SMsgHead
{
public:
    S2UInt32 guids;    // 需要合成的两个雕文guid

    PQTotemGlyphMerge()
    {
        msg_cmd = 763950635;
    }

    virtual ~PQTotemGlyphMerge()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTotemGlyphMerge(*this) );
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
            && TFVarTypeProcess( guids, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTotemGlyphMerge";
    }
};

#endif
