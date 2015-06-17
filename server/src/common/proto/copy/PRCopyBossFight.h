#ifndef _PRCopyBossFight_H_
#define _PRCopyBossFight_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFight.h>
#include <proto/common/S3UInt32.h>

/*返回挑战boss战斗数据*/
class PRCopyBossFight : public SMsgHead
{
public:
    uint32 fight_id;    //战斗Id
    uint32 seed;    //战斗随机种子
    SFight fight;    //战斗数据
    std::vector< S3UInt32 > coins;    //战斗掉落记录

    PRCopyBossFight() : fight_id(0), seed(0)
    {
        msg_cmd = 1415847306;
    }

    virtual ~PRCopyBossFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyBossFight(*this) );
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
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( seed, eType, stream, uiSize )
            && TFVarTypeProcess( fight, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyBossFight";
    }
};

#endif
