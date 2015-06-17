#ifndef _PRTotemGlyphMerge_H_
#define _PRTotemGlyphMerge_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/totem/STotemGlyph.h>

class PRTotemGlyphMerge : public SMsgHead
{
public:
    uint32 is_success;    // 非0表示成功
    uint32 deleted_guid;    // 删除的雕文guid
    STotemGlyph result_glyph;    // 剩下的雕文

    PRTotemGlyphMerge() : is_success(0), deleted_guid(0)
    {
        msg_cmd = 1411759523;
    }

    virtual ~PRTotemGlyphMerge()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTotemGlyphMerge(*this) );
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
            && TFVarTypeProcess( is_success, eType, stream, uiSize )
            && TFVarTypeProcess( deleted_guid, eType, stream, uiSize )
            && TFVarTypeProcess( result_glyph, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTotemGlyphMerge";
    }
};

#endif
