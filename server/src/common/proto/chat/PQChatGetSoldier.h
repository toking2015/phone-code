#ifndef _PQChatGetSoldier_H_
#define _PQChatGetSoldier_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*英雄*/
class PQChatGetSoldier : public SMsgHead
{
public:
    uint32 target_id;
    uint32 soldier_guid;

    PQChatGetSoldier() : target_id(0), soldier_guid(0)
    {
        msg_cmd = 557377059;
    }

    virtual ~PQChatGetSoldier()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQChatGetSoldier(*this) );
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
            && TFVarTypeProcess( soldier_guid, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQChatGetSoldier";
    }
};

#endif
