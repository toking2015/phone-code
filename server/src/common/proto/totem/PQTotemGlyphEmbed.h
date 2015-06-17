#ifndef _PQTotemGlyphEmbed_H_
#define _PQTotemGlyphEmbed_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 雕文镶嵌*/
class PQTotemGlyphEmbed : public SMsgHead
{
public:
    uint32 glyph_guid;    // 雕文guid
    uint32 totem_guid;    // 图腾guid

    PQTotemGlyphEmbed() : glyph_guid(0), totem_guid(0)
    {
        msg_cmd = 476898429;
    }

    virtual ~PQTotemGlyphEmbed()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTotemGlyphEmbed(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTotemGlyphEmbed";
    }
};

#endif
