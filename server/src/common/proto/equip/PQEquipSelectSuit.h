#ifndef _PQEquipSelectSuit_H_
#define _PQEquipSelectSuit_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@选择套装生效等级*/
class PQEquipSelectSuit : public SMsgHead
{
public:
    uint32 equip_type;    //装备[甲]类型 
    uint32 select_level;    //选择的等级[EquipSuit.xls的level]

    PQEquipSelectSuit() : equip_type(0), select_level(0)
    {
        msg_cmd = 479388940;
    }

    virtual ~PQEquipSelectSuit()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQEquipSelectSuit(*this) );
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
            && TFVarTypeProcess( equip_type, eType, stream, uiSize )
            && TFVarTypeProcess( select_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQEquipSelectSuit";
    }
};

#endif
