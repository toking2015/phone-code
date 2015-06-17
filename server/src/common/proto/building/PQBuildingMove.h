#ifndef _PQBuildingMove_H_
#define _PQBuildingMove_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*## 移动建筑*/
class PQBuildingMove : public SMsgHead
{
public:
    uint8 building_type;    //建筑类型
    uint32 building_id;    //建筑id       
    S2UInt32 building_position;    //中心点

    PQBuildingMove() : building_type(0), building_id(0)
    {
        msg_cmd = 346561621;
    }

    virtual ~PQBuildingMove()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBuildingMove(*this) );
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
            && TFVarTypeProcess( building_id, eType, stream, uiSize )
            && TFVarTypeProcess( building_position, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBuildingMove";
    }
};

#endif
