#ifndef _PQEquipReplace_H_
#define _PQEquipReplace_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@装备替换*/
class PQEquipReplace : public SMsgHead
{
public:
    int8 is_replace;    //[0:保留,1:替换]
    uint32 equip_guid;    //新装备的guid

    PQEquipReplace() : is_replace(0), equip_guid(0)
    {
        msg_cmd = 109236104;
    }

    virtual ~PQEquipReplace()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQEquipReplace(*this) );
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
            && TFVarTypeProcess( is_replace, eType, stream, uiSize )
            && TFVarTypeProcess( equip_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQEquipReplace";
    }
};

#endif
