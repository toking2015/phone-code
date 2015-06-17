#ifndef _STotemGlyph_H_
#define _STotemGlyph_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S2UInt32.h>

/* 图腾雕文*/
class STotemGlyph : public wd::CSeq
{
public:
    uint32 guid;    // guid
    uint32 id;    // 图腾雕文id
    uint32 totem_guid;    // 如果镶嵌，对应图腾的guid
    std::vector< S2UInt32 > attr_list;    // 属性
    std::vector< S2UInt32 > hide_attr_list;    // 隐藏属性

    STotemGlyph() : guid(0), id(0), totem_guid(0)
    {
    }

    virtual ~STotemGlyph()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STotemGlyph(*this) );
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
            && TFVarTypeProcess( totem_guid, eType, stream, uiSize )
            && TFVarTypeProcess( attr_list, eType, stream, uiSize )
            && TFVarTypeProcess( hide_attr_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STotemGlyph";
    }
};

#endif
