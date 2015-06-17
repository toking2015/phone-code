#ifndef _PRChatGetSoldier_H_
#define _PRChatGetSoldier_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/soldier/SUserSoldier.h>
#include <proto/fight/SFightExtAble.h>

class PRChatGetSoldier : public SMsgHead
{
public:
    uint32 target_id;
    SUserSoldier soldier_data;
    SFightExtAble ext_able;

    PRChatGetSoldier() : target_id(0)
    {
        msg_cmd = 1530883110;
    }

    virtual ~PRChatGetSoldier()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRChatGetSoldier(*this) );
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
            && TFVarTypeProcess( soldier_data, eType, stream, uiSize )
            && TFVarTypeProcess( ext_able, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRChatGetSoldier";
    }
};

#endif
