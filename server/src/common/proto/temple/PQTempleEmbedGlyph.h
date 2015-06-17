#ifndef _PQTempleEmbedGlyph_H_
#define _PQTempleEmbedGlyph_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 镶嵌神符*/
class PQTempleEmbedGlyph : public SMsgHead
{
public:
    uint32 hole_type;    // 神符类型，kEquipXXX
    uint32 hole_index;    // 镶嵌序号
    uint32 glyph_guid;    // 神符guid

    PQTempleEmbedGlyph() : hole_type(0), hole_index(0), glyph_guid(0)
    {
        msg_cmd = 312492137;
    }

    virtual ~PQTempleEmbedGlyph()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTempleEmbedGlyph(*this) );
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
            && TFVarTypeProcess( hole_type, eType, stream, uiSize )
            && TFVarTypeProcess( hole_index, eType, stream, uiSize )
            && TFVarTypeProcess( glyph_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTempleEmbedGlyph";
    }
};

#endif
