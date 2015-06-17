#ifndef _SBuildingBase_H_
#define _SBuildingBase_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S2UInt32.h>

/*建筑基础信息*/
class SBuildingBase : public wd::CSeq
{
public:
    uint32 target_id;    //拥有者id ( role_id )
    uint32 info_id;    //建筑id（ 同类型建筑,info_id 唯一）
    uint8 info_type;    //建筑类型
    uint16 info_level;    //建筑当前等级
    S2UInt32 info_position;    //建筑中心点位置

    SBuildingBase() : target_id(0), info_id(0), info_type(0), info_level(0)
    {
    }

    virtual ~SBuildingBase()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SBuildingBase(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( info_id, eType, stream, uiSize )
            && TFVarTypeProcess( info_type, eType, stream, uiSize )
            && TFVarTypeProcess( info_level, eType, stream, uiSize )
            && TFVarTypeProcess( info_position, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SBuildingBase";
    }
};

#endif
