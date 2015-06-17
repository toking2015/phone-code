#ifndef _STotemInfo_H_
#define _STotemInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/totem/STotem.h>
#include <proto/totem/STotemGlyph.h>

class STotemInfo : public wd::CSeq
{
public:
    std::vector< STotem > totem_list;    // 图腾列表
    std::vector< STotemGlyph > glyph_list;    // 雕文列表，即雕文背包

    STotemInfo()
    {
    }

    virtual ~STotemInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STotemInfo(*this) );
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
            && TFVarTypeProcess( totem_list, eType, stream, uiSize )
            && TFVarTypeProcess( glyph_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STotemInfo";
    }
};

#endif
