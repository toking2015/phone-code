#ifndef _SMarketIndices_H_
#define _SMarketIndices_H_

#include <weedong/core/seq/seq.h>
/*============================数据中心========================*/
class SMarketIndices : public wd::CSeq
{
public:
    std::vector< uint32 > paper_list;    //图纸分类索引, < cargo_id >
    std::vector< uint32 > material_list;    //材料分类索引, < cargo_id >

    SMarketIndices()
    {
    }

    virtual ~SMarketIndices()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMarketIndices(*this) );
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
            && TFVarTypeProcess( paper_list, eType, stream, uiSize )
            && TFVarTypeProcess( material_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMarketIndices";
    }
};

#endif
