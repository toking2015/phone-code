#ifndef _PRPaperCopyMaterialPoint_H_
#define _PRPaperCopyMaterialPoint_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/paper/SUserCopyMaterial.h>

/*资源点更新*/
class PRPaperCopyMaterialPoint : public SMsgHead
{
public:
    SUserCopyMaterial info;    //采集数据

    PRPaperCopyMaterialPoint()
    {
        msg_cmd = 1793480676;
    }

    virtual ~PRPaperCopyMaterialPoint()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPaperCopyMaterialPoint(*this) );
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
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPaperCopyMaterialPoint";
    }
};

#endif
