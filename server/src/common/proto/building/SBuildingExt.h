#ifndef _SBuildingExt_H_
#define _SBuildingExt_H_

#include <weedong/core/seq/seq.h>
class SBuildingExt : public wd::CSeq
{
public:
    uint32 production;    //产出, 库存， 上限
    uint32 time_point;    //时间点，如金库：上次产出的时间点

    SBuildingExt() : production(0), time_point(0)
    {
    }

    virtual ~SBuildingExt()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SBuildingExt(*this) );
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
            && TFVarTypeProcess( production, eType, stream, uiSize )
            && TFVarTypeProcess( time_point, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SBuildingExt";
    }
};

#endif
