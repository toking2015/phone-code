#ifndef _SCopyBossFight_H_
#define _SCopyBossFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S3UInt32.h>

/*副本BOSS挑战临时结构*/
class SCopyBossFight : public wd::CSeq
{
public:
    uint8 mopup_type;    //副本扫荡类型
    uint32 boss_id;    //挑战boss monster id
    uint32 fight_id;
    uint32 seed;
    std::vector< S3UInt32 > coins;    //战斗掉落记录

    SCopyBossFight() : mopup_type(0), boss_id(0), fight_id(0), seed(0)
    {
    }

    virtual ~SCopyBossFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SCopyBossFight(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( mopup_type, eType, stream, uiSize )
            && TFVarTypeProcess( boss_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( seed, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SCopyBossFight";
    }
};

#endif
