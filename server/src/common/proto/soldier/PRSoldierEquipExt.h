#ifndef _PRSoldierEquipExt_H_
#define _PRSoldierEquipExt_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>
#include <proto/fight/SFightExtAble.h>

class PRSoldierEquipExt : public SMsgHead
{
public:
    S2UInt32 soldier;    //武将 first:武将背包类型 second:武将guid
    SFightExtAble able;    //装备二级属性

    PRSoldierEquipExt()
    {
        msg_cmd = 1961337467;
    }

    virtual ~PRSoldierEquipExt()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSoldierEquipExt(*this) );
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
            && TFVarTypeProcess( able, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSoldierEquipExt";
    }
};

#endif
