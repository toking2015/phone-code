#ifndef _PQItemEquipSkill_H_
#define _PQItemEquipSkill_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

/*@@装备穿戴*/
class PQItemEquipSkill : public SMsgHead
{
public:
    S2UInt32 src;    //装备物品[first:bag_index, second:item_guid]
    uint32 soldier_guid;    //武将guid

    PQItemEquipSkill() : soldier_guid(0)
    {
        msg_cmd = 103471093;
    }

    virtual ~PQItemEquipSkill()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQItemEquipSkill(*this) );
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
            && TFVarTypeProcess( src, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQItemEquipSkill";
    }
};

#endif
