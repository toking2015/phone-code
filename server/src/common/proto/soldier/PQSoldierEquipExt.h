#ifndef _PQSoldierEquipExt_H_
#define _PQSoldierEquipExt_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@请求武将装备二级属性*/
class PQSoldierEquipExt : public SMsgHead
{
public:
    S2UInt32 soldier;    //武将 first:武将背包类型 second:武将guid

    PQSoldierEquipExt()
    {
        msg_cmd = 76490040;
    }

    virtual ~PQSoldierEquipExt()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSoldierEquipExt(*this) );
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
            && TFVarTypeProcess( soldier, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQSoldierEquipExt";
    }
};

#endif
