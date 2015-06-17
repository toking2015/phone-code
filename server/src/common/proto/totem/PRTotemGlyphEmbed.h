#ifndef _PRTotemGlyphEmbed_H_
#define _PRTotemGlyphEmbed_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTotemGlyphEmbed : public SMsgHead
{
public:
    uint32 glyph_guid;    // 雕文guid, 来自PQTotemGlyphEmbed
    uint32 totem_guid;    // 图腾guid, 来自PQTotemGlyphEmbed
    uint32 is_new;    // 将glyph_guid的雕文的totem_guid设置为totem_guid, 如果非新增，删除deleted_guid的雕文
    uint32 deleted_guid;    // 删除的雕文guid

    PRTotemGlyphEmbed() : glyph_guid(0), totem_guid(0), is_new(0), deleted_guid(0)
    {
        msg_cmd = 1323933723;
    }

    virtual ~PRTotemGlyphEmbed()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTotemGlyphEmbed(*this) );
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
            && TFVarTypeProcess( glyph_guid, eType, stream, uiSize )
            && TFVarTypeProcess( totem_guid, eType, stream, uiSize )
            && TFVarTypeProcess( is_new, eType, stream, uiSize )
            && TFVarTypeProcess( deleted_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTotemGlyphEmbed";
    }
};

#endif
