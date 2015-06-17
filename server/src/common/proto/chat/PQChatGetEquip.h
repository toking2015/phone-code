#ifndef _PQChatGetEquip_H_
#define _PQChatGetEquip_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*装备*/
class PQChatGetEquip : public SMsgHead
{
public:
    uint32 target_id;
    uint32 equip_type;
    uint32 equip_level;

    PQChatGetEquip() : target_id(0), equip_type(0), equip_level(0)
    {
        msg_cmd = 839851394;
    }

    virtual ~PQChatGetEquip()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQChatGetEquip(*this) );
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
            && TFVarTypeProcess( equip_type, eType, stream, uiSize )
            && TFVarTypeProcess( equip_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQChatGetEquip";
    }
};

#endif
