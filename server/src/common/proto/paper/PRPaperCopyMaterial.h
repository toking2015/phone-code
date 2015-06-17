#ifndef _PRPaperCopyMaterial_H_
#define _PRPaperCopyMaterial_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/paper/SUserCopyMaterial.h>

/*资源点列表更新*/
class PRPaperCopyMaterial : public SMsgHead
{
public:
    std::vector< SUserCopyMaterial > material_list;

    PRPaperCopyMaterial()
    {
        msg_cmd = 1531515678;
    }

    virtual ~PRPaperCopyMaterial()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPaperCopyMaterial(*this) );
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
            && TFVarTypeProcess( material_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPaperCopyMaterial";
    }
};

#endif
