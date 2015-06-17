#ifndef _STempleGlyph_H_
#define _STempleGlyph_H_

#include <weedong/core/seq/seq.h>
/* 神符*/
class STempleGlyph : public wd::CSeq
{
public:
    uint32 guid;    // guid
    uint32 id;    // 神符id
    uint32 level;    // 等级
    uint32 exp;    // 经验
    uint32 embed_type;    // 如果镶嵌，非0对应镶嵌的类型
    uint32 embed_index;    // 如果镶嵌，对应的序号，从0开始

    STempleGlyph() : guid(0), id(0), level(0), exp(0), embed_type(0), embed_index(0)
    {
    }

    virtual ~STempleGlyph()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STempleGlyph(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( exp, eType, stream, uiSize )
            && TFVarTypeProcess( embed_type, eType, stream, uiSize )
            && TFVarTypeProcess( embed_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STempleGlyph";
    }
};

#endif
