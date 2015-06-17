#ifndef _PQBuildingUpgrade_H_
#define _PQBuildingUpgrade_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*## 升级建筑*/
class PQBuildingUpgrade : public SMsgHead
{
public:
    uint8 building_type;    //建筑类型
    uint32 building_id;    //建筑id       

    PQBuildingUpgrade() : building_type(0), building_id(0)
    {
        msg_cmd = 600117215;
    }

    virtual ~PQBuildingUpgrade()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBuildingUpgrade(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBuildingUpgrade";
    }
};

#endif
