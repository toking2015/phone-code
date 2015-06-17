#ifndef _SUserFormation_H_
#define _SUserFormation_H_

#include <weedong/core/seq/seq.h>
/*阵型-印佳*/
class SUserFormation : public wd::CSeq
{
public:
    uint32 guid;    //guid
    uint32 attr;    //玩家属性
    uint32 formation_type;    //阵型类型
    uint32 formation_index;    //阵型索引

    SUserFormation() : guid(0), attr(0), formation_type(0), formation_index(0)
    {
    }

    virtual ~SUserFormation()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserFormation(*this) );
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
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( formation_type, eType, stream, uiSize )
            && TFVarTypeProcess( formation_index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserFormation";
    }
};

#endif
