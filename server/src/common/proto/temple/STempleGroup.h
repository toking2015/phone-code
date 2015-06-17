#ifndef _STempleGroup_H_
#define _STempleGroup_H_

#include <weedong/core/seq/seq.h>
/* 神殿组合*/
class STempleGroup : public wd::CSeq
{
public:
    uint32 id;    // id
    uint32 level;    // 等级

    STempleGroup() : id(0), level(0)
    {
    }

    virtual ~STempleGroup()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STempleGroup(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STempleGroup";
    }
};

#endif
