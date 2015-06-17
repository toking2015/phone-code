#ifndef _SUserBuilding_H_
#define _SUserBuilding_H_

#include <weedong/core/seq/seq.h>
#include <proto/building/SBuildingBase.h>
#include <proto/building/SBuildingExt.h>

class SUserBuilding : public wd::CSeq
{
public:
    uint8 building_type;    //建筑类型<等同data.info_type>
    uint32 building_guid;    //建筑id<等同data.info_id>
    SBuildingBase data;
    SBuildingExt ext;

    SUserBuilding() : building_type(0), building_guid(0)
    {
    }

    virtual ~SUserBuilding()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserBuilding(*this) );
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
            && TFVarTypeProcess( building_type, eType, stream, uiSize )
            && TFVarTypeProcess( building_guid, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && TFVarTypeProcess( ext, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserBuilding";
    }
};

#endif
