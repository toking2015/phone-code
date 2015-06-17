#ifndef _PQBuildingAdd_H_
#define _PQBuildingAdd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*## 激活建筑*/
class PQBuildingAdd : public SMsgHead
{
public:
    uint8 building_type;    //建筑类型
    S2UInt32 building_position;    //中心点

    PQBuildingAdd() : building_type(0)
    {
        msg_cmd = 462722994;
    }

    virtual ~PQBuildingAdd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBuildingAdd(*this) );
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
            && TFVarTypeProcess( building_type, eType, stream, uiSize )
            && TFVarTypeProcess( building_position, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBuildingAdd";
    }
};

#endif
