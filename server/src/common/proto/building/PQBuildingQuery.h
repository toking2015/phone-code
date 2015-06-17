#ifndef _PQBuildingQuery_H_
#define _PQBuildingQuery_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*## 查询建筑*/
class PQBuildingQuery : public SMsgHead
{
public:
    uint32 target_id;    //目标id ( role_id )
    uint8 building_type;    //建筑类型
    uint32 building_id;    //建筑id

    PQBuildingQuery() : target_id(0), building_type(0), building_id(0)
    {
        msg_cmd = 989836134;
    }

    virtual ~PQBuildingQuery()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBuildingQuery(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( building_type, eType, stream, uiSize )
            && TFVarTypeProcess( building_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBuildingQuery";
    }
};

#endif
