#ifndef _PQCopyBossFight_H_
#define _PQCopyBossFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*挑战boss*/
class PQCopyBossFight : public SMsgHead
{
public:
    uint8 mopup_type;    //挑战boss类型 [ kCopyMopupTypeNormal, kCopyMopupTypeElite ]
    uint32 boss_id;    //挑战boss的 monster_id

    PQCopyBossFight() : mopup_type(0), boss_id(0)
    {
        msg_cmd = 257944230;
    }

    virtual ~PQCopyBossFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyBossFight(*this) );
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
            && TFVarTypeProcess( mopup_type, eType, stream, uiSize )
            && TFVarTypeProcess( boss_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyBossFight";
    }
};

#endif
