#ifndef _SUserSBuilding_H_
#define _SUserSBuilding_H_

#include <weedong/core/seq/seq.h>
#include <proto/building/SBuildingBase.h>
#include <proto/building/SBuildingExt.h>

class SUserSBuilding : public wd::CSeq
{
public:
    SBuildingBase data;
    SBuildingExt ext;

    SUserSBuilding()
    {
    }

    virtual ~SUserSBuilding()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserSBuilding(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( data, type, stream, uiSize )
            && TFVarTypeProcess( ext, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
};

#endif
