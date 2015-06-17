#ifndef _SFightClientLog_H_
#define _SFightClientLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/client/SFightClientSeed.h>
#include <proto/fight/SFightPlayerInfo.h>
#include <proto/client/SFightClientSkillObject.h>
#include <proto/client/SFightClientRoundData.h>

class SFightClientLog : public wd::CSeq
{
public:
    uint32 fight_id;
    uint32 fight_type;
    SFightClientSeed fight_randomseed;
    std::vector< SFightPlayerInfo > fight_info_list;
    std::vector< SFightClientSkillObject > round_soldier;
    std::vector< SFightClientRoundData > round_data_list;
    std::vector< SFightClientRoundData > totem_skill_list;

    SFightClientLog() : fight_id(0), fight_type(0)
    {
    }

    virtual ~SFightClientLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightClientLog(*this) );
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
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_type, eType, stream, uiSize )
            && TFVarTypeProcess( fight_randomseed, eType, stream, uiSize )
            && TFVarTypeProcess( fight_info_list, eType, stream, uiSize )
            && TFVarTypeProcess( round_soldier, eType, stream, uiSize )
            && TFVarTypeProcess( round_data_list, eType, stream, uiSize )
            && TFVarTypeProcess( totem_skill_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightClientLog";
    }
};

#endif
